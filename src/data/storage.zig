const std = @import("std");
const print = std.debug.print;
const exit = std.process.exit;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

const Tree = @import("objects.zig").Tree;
const Blob = @import("objects.zig").Blob;




pub fn writeTreeToBuffer(allocator: Allocator, cwd: std.fs.Dir, path : [] const u8) ![] const u8
{
    var openedPath = try cwd.openDir(path, .{.iterate = true});
    defer openedPath.close();

    const pathBaseName = std.fs.path.basename(path);
    var pathTree = Tree.init(allocator, openedPath, pathBaseName);
    defer pathTree.denit();

    var data = ArrayList(u8).init(allocator);
    defer data.deinit();

    try data.appendSlice(pathBaseName);
    try data.appendSlice("\n");

    for(pathTree.trees.items) |tree|
    {
        try data.appendSlice("D\t");
        try appendAsHex(&data,&tree.hashData);
        //double t for allignment
        try data.appendSlice("\t\t");
        try data.appendSlice(&tree.treename);
        try data.appendSlice("\n");
    }

    for(pathTree.blobs.items) |blob|
    {
        try data.appendSlice("F\t");
        try appendAsHex(&data,&blob.hashData);
        try data.appendSlice("\t");
        if(blob.executeFlag){
            try data.appendSlice("E");
        }
        else {
            try data.appendSlice("N");
        }
        try data.appendSlice("\t");
        try data.appendSlice(&blob.fname);
        try data.appendSlice("\n");
    }
    
    const buffer = try allocator.alloc(u8, data.items.len);
    std.mem.copyForwards(u8, buffer, data.items);
    return buffer;
}

fn appendAsHex(list : *ArrayList(u8), hash: [] const u8) !void
{
    for(0..hash.len) |i|
    {
        var byte = hash[i];
        if(i % 2 == 0 ){
            byte = byte & 0x0f;
        }
        else{
            byte = byte >> 4; 
        }
        
        const mappedVal = try mapByte(byte);
        try list.append(mappedVal);
    }
}

pub const ByteMap = error{InvalidMap};
fn mapByte(byte: u8) !u8
{
    return switch (byte) 
    {
        0 => '0',
        1 => '1',
        2 => '2',
        3 => '3',
        4 => '4',
        5 => '5',
        6 => '6',
        7 => '7',
        8 => '8',
        9 => '9',
        10 => 'a',
        11 => 'b',
        12 => 'c',
        13 => 'd',
        14 => 'e',
        15 => 'f',
        else => ByteMap.InvalidMap
    };
}