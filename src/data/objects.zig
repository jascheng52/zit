const std = @import("std");
const ArrayList = std.ArrayList;

const hashFunc = std.crypto.hash.Blake3.hash;
const print = std.debug.print;
const exit = std.process.exit;
const fs = std.fs;

const Blob = struct {
    data: [] u8,
    hashData : [256] u8,
    fname: [256]u8,
    allocator : std.mem.Allocator,
    executeFlag: bool,

    const Self =@This();
    fn hash(self: *Self) void
    {

        const hashVal = self.allocator.alloc(u8, 256) catch |err| {print("{}\n",.{err});exit(0);};
        defer self.allocator.free(hashVal);
        
        hashFunc(self.data, hashVal, .{});

        std.mem.copyForwards(u8, &self.hashData, hashVal);
        
        return;
    }

    pub fn init(allocator: std.mem.Allocator, data : [] u8, fname : []u8, permissions: usize) Self
    {
        var self =Self{
            .data = data,
            .hashData = [_]u8{0} ** 256, 
            .fname = [_]u8{0} ** 256,
            .allocator = allocator,
            //Bit masking for exexute check
            .executeFlag = permissions & 0o111 != 0,
        };
        self.hash();
        std.mem.copyForwards(u8, &self.fname, fname);
        return self;

    }

    fn deinit(self: Self) void
    {   
        self.allocator.free(self.data);
    }
    fn printBlob(self: Blob, level: u32) void
    {
        for(0..level) |i|
        {
            std.debug.print("\t", .{});
            _=i;
        }
        print("fname: {s}\n", .{self.fname});
        print("Can execute: {}\n", .{self.executeFlag});

        for(0..level) |i|
        {
            std.debug.print("\t", .{});
            _=i;
        }
        
        print("hash: {x}\n", .{self.hashData[0..5]});

    }
};


pub const Tree = struct {
    trees: ArrayList(Tree),
    blobs: ArrayList(Blob),
    data : []u8,
    hashData : [256] u8,
    treename : [256] u8,
    allocator : std.mem.Allocator,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator, cwd: fs.Dir, treeName: [] const u8) Self
    {

        var self = Self{
            .trees = ArrayList(Tree).init(allocator),
            .blobs = ArrayList(Blob).init(allocator),
            .data = undefined,
            .hashData = [_]u8 {0} ** 256,
            .treename = [_]u8 {0} ** 256,
            .allocator = allocator,
            
        };
        std.mem.copyForwards(u8, &self.treename, treeName);

        
        var cwdIter = cwd.iterate();
        while(cwdIter.next() catch |err| {print("{}\n",.{err});exit(0);}) |inode|
        {
            if(inode.kind == std.fs.File.Kind.directory)
            {
                if(std.mem.eql(u8, inode.name, ".zit"))
                    continue;
                var subTreeDir  = cwd.openDir(inode.name, .{.iterate = true}) catch |err| {print("{}\n",.{err});exit(0);};
                defer subTreeDir.close();

                const subTree = Tree.init(allocator, subTreeDir,inode.name);
                self.trees.append(subTree) catch |err| {print("{}\n",.{err});exit(0);};

                // dataList.append(subTree.data);
            }
            else 
            {
                if(std.mem.eql(u8, inode.name, "zit"))
                {
                    continue;
                }
                const inodeFile = cwd.openFile(inode.name, .{}) catch |err| {print("{}\n",.{err});exit(0);};
                defer inodeFile.close();

                const stat = inodeFile.stat() catch |err| {print("{}\n",.{err});exit(0);};
                const metadata = inodeFile.metadata() catch |err| {print("{}\n",.{err});exit(0);};
                
            
                const buffer = inodeFile.readToEndAlloc(allocator, stat.size) catch |err| {print("{}\n",.{err});exit(0);};
                const res: [] u8 =  @constCast(inode.name);

                
                const newBlob = Blob.init(allocator, buffer, res, metadata.permissions().inner.mode);

                self.blobs.append(newBlob) catch |err| {print("{}\n",.{err});exit(0);};
                // newBlob.printBlob();
            }
            
        }
        
        
        self.hash();
        return self;
    }
    pub fn denit(self: Self) void
    {
        for(self.trees.items) |tree|
        {
            tree.denit();
        }
        for(self.blobs.items) |blob|
        {
            blob.deinit();
        }

        self.trees.deinit();
        self.blobs.deinit();
    }


    pub fn printTree(self: Self, level : u32) void
    {
        for(0..level) |i|
        {
            std.debug.print("\t", .{});
            _=i;
        }
        print("Tree Name : {s}\n", .{ self.treename});
        for(0..level) |i|
        {
            std.debug.print("\t", .{});
            _=i;
        }
        print("Tree Hash : {x}\n", .{ self.hashData[0..5]});
        for(self.trees.items) |tree|
        {
            tree.printTree(level + 1);
        }
        for(self.blobs.items) |blob|
        {
            blob.printBlob(level);
        }
    }

    fn hash(self: *Self) void
    {
        var subHashesList = ArrayList(u8).init(self.allocator);
        defer subHashesList.deinit();
        for(self.trees.items) |tree|
        {
            subHashesList.appendSlice(&tree.hashData) catch |err| {print("{}\n",.{err});exit(0);};
        }
        for(self.blobs.items) |blob|
        {
             subHashesList.appendSlice(&blob.hashData) catch |err| {print("{}\n",.{err});exit(0);};
        }
        
        hashFunc(subHashesList.items, &self.hashData, .{});
    }
};