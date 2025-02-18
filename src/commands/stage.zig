const std = @import("std");
const print = std.debug.print;
const ListByte = std.ArrayList(u8);

const objects = @import("../data/objects.zig");
const storage = @import("../data/storage.zig");
const commands = @import("commands.zig");

pub fn com_stage(args: *std.process.ArgIterator) !void
{

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer print( "From stage: {} \n", .{gpa.deinit()});

    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    defer arena.deinit();
    const arenaAllocator = arena.allocator();

    const pathNext = args.next();
    if (pathNext == null) {
        print("Pass in files to stage.\n", .{});
        return;
    }
    const path = pathNext.?;

    var cwd = std.fs.cwd();
    const entry =  try cwd.statFile(path);

    const current = try cwd.openFile(commands.ZIT_HEAD_CURRENT_FI, .{  });
    defer current.close();

    const stageDir = try cwd.openDir(commands.ZIT_STAGE_DIR, .{});
    
    if(entry.kind == std.fs.File.Kind.directory)
    {
        
        const entryTree = objects.Tree.init(arenaAllocator, cwd, path);

        try stageTree(arenaAllocator,entryTree, stageDir);
        
    }
    else 
    {
        const blobFile = try cwd.openFile(path, .{});
        const meta = try blobFile.metadata();
        const buffer = try arenaAllocator.alloc(u8, meta.size());

        _ = try blobFile.readAll(buffer);
        const createdBlob = objects.Blob.init(arenaAllocator, buffer, @constCast(std.fs.path.basename(path)), 
                meta.permissions().inner.mode);
        try stageBlob(arenaAllocator,createdBlob, stageDir);
        
    }   
}



pub fn stageTree(allocator: std.mem.Allocator, tree: objects.Tree, stageDir: std.fs.Dir) !void
{
    for(tree.trees.items) |subtree|
    {
        try stageTree(allocator, subtree, stageDir);
    }

    for(tree.blobs.items) |blob|
    {
        try stageBlob(allocator, blob, stageDir);
    }
}

pub fn stageBlob(allocator: std.mem.Allocator, blob: objects.Blob, stageDir: std.fs.Dir) !void
{
    var hexName = try allocator.alloc(u8, blob.hashData.len * 2);
    defer allocator.free(hexName);
    
    for(0..blob.hashData.len) |i|
    {
        const byte = blob.hashData[i];
        const upper = byte >> 4; 
        const lower = byte & 0x0f;
        
        const mappedUpper = try storage.mapByte(upper);
        const mappedLower = try storage.mapByte(lower);

        hexName[i*2] = mappedUpper;                
        hexName[i*2 + 1] = mappedLower;

    }
        print("{s} \n", .{hexName});

    const blobFile = try stageDir.createFile(hexName, .{});
    _ = try blobFile.writeAll(blob.data);

}


