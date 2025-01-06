const std = @import("std");
const print = std.debug.print;

pub fn init() !void
{
    // var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // defer print( "From init: {} \n", .{gpa.deinit()});

    // const allocator = gpa.allocator();

    var cwd = std.fs.cwd();

    cwd.access(".zit", .{}) catch {
        try cwd.makeDir(".zit");
        try cwd.makeDir(".zit/HEAD");
        try cwd.makeDir(".zit/obj");
        try cwd.makeDir(".zit/commits");
        try cwd.makeDir(".zit/branches");
        
        return;

    };
    
    _ = try std.io.getStdOut().write("Zit alreadly initialized\n");

}