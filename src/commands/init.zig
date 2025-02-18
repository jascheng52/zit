const std = @import("std");
const print = std.debug.print;
const commands = @import("commands.zig");

pub fn com_init() !void {
    var cwd = std.fs.cwd();

    cwd.access(".zit", .{}) catch {
        try cwd.makeDir(commands.ZIT_DIR);
        try cwd.makeDir(commands.ZIT_HEAD_DIR);
        try cwd.makeDir(commands.ZIT_OBJ_DIR);
        try cwd.makeDir(commands.ZIT_COMMITS_DIR);
        try cwd.makeDir(commands.ZIT_BRANCHES_DIR);
        try cwd.makeDir(commands.ZIT_STAGE_DIR);
        try cwd.makeDir(commands.ZIT_WORK_DIR);

        const branchDir = try cwd.openDir(commands.ZIT_BRANCHES_DIR, .{});
        commands.branch_create(commands.MAIN_BRANCH, &branchDir);

        var zitDir = try cwd.openDir(commands.ZIT_DIR, .{});
        commands.change_branch(&zitDir, commands.MAIN_BRANCH);

        return;
    };

    _ = try std.io.getStdOut().write("Zit alreadly initialized\n");
}
