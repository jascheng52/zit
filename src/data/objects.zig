const std = @import("std");
const ArrayList = std.ArrayList;

const SEED : u64 = 1703;
const stdHash = std.hash.XxHash64.hash;
const print = std.debug.print;
const fs = std.fs;

const Blob = struct {
    data: [] u8,
    hashData : u64,

    fn hash(self: Blob) u64
    {
        return stdHash(SEED, self.data);
    }

    pub fn fillData(self: *Blob) void
    {
        self.hashData = self.hash();
    }

    fn printBlob(self: Blob) void
    {
        print("data: {s} --hash: {d}\n", .{self.data, self.hashData});
    }
};


pub const Tree = struct {
    trees: *ArrayList(Tree),
    blobs: ArrayList(Blob),
    data : []u8,
    hashData : u64,

    fn hash(self: Tree)u64
    {
        return stdHash(SEED, self.data);
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
                
                var newBlob = Blob{.data = buffer, .hashData = 0};
                newBlob.fillData();

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


