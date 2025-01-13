const std = @import("std");
const print = std.debug.print;
const commands = @import("commands.zig");

pub fn com_change(args: *std.process.ArgIterator) !void
{
    var cwd = std.fs.cwd();
    var zitDir = cwd.openDir(commands.ZIT_DIR, .{}) catch {
        print("Zit not initialized\n", .{});
        return;
    };
    
    const branchName = args.next();
    if(branchName == null)
    {
        print("Missing branch name \n", .{});
        return;
    }

    changeBranch(&zitDir, branchName.?);

    
}

pub fn changeBranch(zitDir: *std.fs.Dir, branch: []const u8) void 
{
    
    const writeOptions : std.fs.Dir.WriteFileOptions =.{.sub_path = commands.HEAD_CURRENT_FI, 
                                                        .data = branch,
                                                        .flags = .{}};
    zitDir.writeFile(writeOptions) catch {
        print("Failed to write file: {s}\n", .{commands.HEAD_CURRENT_FI});
        return;
    };
    print("Changing to branch: {s}\n", .{branch});

}

