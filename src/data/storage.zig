const std = @import("std");
const print = std.debug.print;
const exit = std.process.exit;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

const Tree = @import("objects.zig").Tree;
const Blob = @import("objects.zig").Blob;




pub fn writeTreeToBuffer(allocator: Allocator, cwd: std.fs.Dir, 
                        path : [] const u8) ![] const u8
{
    var openedPath = try cwd.openDir(path, .{.iterate = true});
    defer openedPath.close();

    const pathBaseName = std.fs.path.basename(path);
    var pathTree = Tree.init(allocator, openedPath, pathBaseName);
    defer pathTree.denit();

    var data = ArrayList(u8).init(allocator);
    defer data.deinit();

    try data.appendSlice(pathBaseName);

    for(pathTree.trees.items) |tree|
    {
        try data.appendSlice("\nD\t");
        try appendAsHex(&data,&tree.hashData);
        //double t for allignment
        try data.appendSlice("\t\t");
        try data.appendSlice(&tree.treename);
    }

    for(pathTree.blobs.items) |blob|
    {
        try data.appendSlice("\nF\t");
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
    }
    
    const buffer = try allocator.alloc(u8, data.items.len);
    std.mem.copyForwards(u8, buffer, data.items);
    return buffer;
}

pub fn appendAsHex(list : *ArrayList(u8), hash: [] const u8) !void
{
    for(0..hash.len) |i|
    {
        const byte = hash[i];

        const lower = byte & 0x0f;
        const upper = byte >> 4; 
        // if(i % 2 == 0 ){
        //     byte = byte & 0x0f;
        // }
        // else{
        //     byte = byte >> 4; 
        // }
        
        // const mappedVal = try mapByte(byte);
        const mappedValUpper = try mapByte(upper);
        const mappedValLower = try mapByte(lower);

        try list.append(mappedValUpper);
        try list.append(mappedValLower);

    }
}

pub const ByteMap = error{InvalidMap};
pub fn mapByte(byte: u8) !u8
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

fn mapLetter(letter: u8) !u8
{
    return switch (letter) 
    {
        '0' => 0,
        '1' => 1,
        '2' => 2,
        '3' => 3,
        '4' => 4,
        '5' => 5,
        '6' => 6,
        '7' => 7,
        '8' => 8,
        '9' => 9,
        'a' => 10,
        'b' => 11,
        'c' => 12,
        'd' => 13,
        'e' => 14,
        'f' => 15,
        else => ByteMap.InvalidMap
    };
}