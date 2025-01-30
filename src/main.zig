const std = @import("std");
const commands = @import("commands/commands.zig");
const COMMAND_TYPE = commands.COMMAND_TYPE;

const Tree = @import("data/objects.zig").Tree;
const Storage = @import("data/storage.zig");

const print = std.debug.print;

pub fn main() !void 
{

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer print( "From main: {} \n", .{gpa.deinit()});

    const allocator = gpa.allocator();

    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();
    _ = args.skip();

    const comArg = args.next() orelse { help(); std.process.exit(0);};
    // if(comArg == null) { help();}

    const cwd = std.fs.cwd();
    const iter = try cwd.openDir(".", .{ .iterate = true });
    const buffer = try Storage.writeTreeToBuffer(allocator, iter, ".");
    defer allocator.free(buffer);
    print("{s}\n", .{buffer});
    var file = try std.fs.cwd().createFile("test", .{});
    defer file.close();
    try file.writeAll(buffer);
    // std.process.exit(0);

    const comCase : COMMAND_TYPE= std.meta.stringToEnum(COMMAND_TYPE, comArg) orelse COMMAND_TYPE.NA;
    try switch (comCase)
    {
        COMMAND_TYPE.init => commands.com_init(),
        COMMAND_TYPE.branch => commands.com_branch(&args),
        COMMAND_TYPE.change => commands.com_change(&args),
        else => help(),
    };

    

}

pub fn help() void
{
    print("Usage: \n", .{});
    print("init\t Initialize zit repo\n", .{});
    std.process.exit(0);
}