const std = @import("std");
const ArrayList = std.ArrayList;

const SEED : u64 = 1703;
const hashFunc = std.crypto.hash.Blake3.hash;
const print = std.debug.print;
const fs = std.fs;

const Blob = struct {
    data: [] u8,
    hashData : [256] u8,
    allocator : std.mem.Allocator,

    const Self =@This();
    fn hash(self: *Self) void
    {

        const hashVal = self.allocator.alloc(u8, 256) catch |err| {
            print("{}\n", .{err});
            std.process.exit(0);
        };
        defer self.allocator.free(hashVal);
        
        hashFunc(self.data, hashVal, .{});

        std.mem.copyForwards(u8, &self.hashData, hashVal);
        // print( "{X} \n",.{self.hashData});
        // std.process.exit(0);
        return;
    }

    pub fn init(allocator: std.mem.Allocator, data : [] u8) Self
    {
        var self =Self{
            .data = data,
            .hashData = [_]u8{0} ** 256, 
            .allocator = allocator,
        };
        self.hash();
        return self;

    }

    fn deinit(self: Self) void
    {   
        self.allocator.free(self.data);
    }
    fn printBlob(self: Blob) void
    {
        print("data: {s}\nhash: {x}\n", .{self.data, self.hashData});
    }
};


pub const Tree = struct {
    trees: *ArrayList(Tree),
    blobs: ArrayList(Blob),
    data : []u8,
    hashData : [] u8,

    fn hash(self: Tree)u64
    {

        return hashFunc(self.data, self.hashData, .{});
    }

    pub fn init(allocator: std.mem.Allocator, cwd: fs.Dir) !*Tree
    {
        const selfTree = try allocator.create(Tree);
        selfTree.blobs = ArrayList(Blob).init(allocator);
        
        var dataList = ArrayList([]u8).init(allocator);
        _=&dataList;
        defer dataList.deinit();
        
        var cwdIter = cwd.iterate();
        while(cwdIter.next() catch |err| {
            print("Tree iterator : {}\n", .{err});
            std.process.exit(0);
        }) |inode|
        {
            
            print("name: {s}\n", .{inode.name});
            if(inode.kind == std.fs.File.Kind.directory)
            {
                if(std.mem.eql(u8, inode.name, ".zit"))
                    continue;
                const subTree = try Tree.init(allocator, try cwd.openDir(inode.name, .{.iterate = true}));
                _= subTree;
                // dataList.append(subTree.data);
            }
            else 
            {
                if(std.mem.eql(u8, inode.name, "zit"))
                {
                    print("Here\n", .{});
                    // std.process.exit(0);
                    continue;
                }
                const inodeFile = try cwd.openFile(inode.name, .{});
                defer inodeFile.close();
                const stat = try inodeFile.stat();
                const buffer = try inodeFile.readToEndAlloc(allocator, stat.size);
                
                const newBlob = Blob.init(allocator, buffer);

                try selfTree.blobs.append(newBlob);
                // newBlob.printBlob();
            }
            
        }
            
        for(selfTree.blobs.items) |i|
        {
            i.printBlob();
        }
        return selfTree;
    }

};


