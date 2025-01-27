const std = @import("std");
const commands = @import("commands/commands.zig");
const COMMAND_TYPE = commands.COMMAND_TYPE;

const Tree = @import("data/objects.zig").Tree;
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
    const rootTree = Tree.init(allocator,iter, ".");
    rootTree.printTree(0);
    rootTree.denit();
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