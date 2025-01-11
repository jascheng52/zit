const std = @import("std");
const commands = @import("commands/commands.zig");
const COMMAND_TYPE = commands.COMMAND_TYPE;

const print = std.debug.print;

pub fn main() !void 
{
    print("Hello t\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer print( "From main: {} \n", .{gpa.deinit()});

    const allocator = gpa.allocator();

    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();
    _ = args.skip();

    const comArg = args.next() orelse { help(); std.process.exit(0);};
    // if(comArg == null) { help();}


    const comCase : COMMAND_TYPE= std.meta.stringToEnum(COMMAND_TYPE, comArg) orelse COMMAND_TYPE.NA;
    try switch (comCase)
    {
        COMMAND_TYPE.init => commands.init(),
        COMMAND_TYPE.branch => commands.branch(&args),
        else => help(),
    };
    

}

pub fn help() void
{
    print("Usage: \n", .{});
    print("init\t Initialize zit repo\n", .{});
    std.process.exit(0);
}