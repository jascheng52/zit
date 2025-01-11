const std = @import("std");
const print = std.debug.print;

const BranchError = error {
    BranchExist,
};

pub fn branch(args: *std.process.ArgIterator) !void {
    var cwd = std.fs.cwd();
    const zitDir = cwd.openDir(".zit", .{}) catch |err| {
        print("Zit not initialized\n", .{});
        return err;
    };
    const branchesDir = zitDir.openDir("branches", .{ .iterate = true }) catch |err| {
        print("Zit branches dir missing", .{});
        return err;
    };

    _ = &cwd;

    const nextArg = args.next();
    if (nextArg == null) {
        try printBranches(&branchesDir);
        return;
    }

    const branchArg = nextArg.?;

    try createBranch(branchArg, &branchesDir);
}

fn createBranch(branchName: []const u8, branchDir: *const std.fs.Dir) !void {
    _ = branchDir.openDir(branchName, .{}) catch {

        _ = branchDir.makeDir(branchName) catch |errBranch| {
            print("Failed to make branch {s}", .{branchName});
            return errBranch;
        };
        return;
        
    };
    print("Branch {s} already exists", .{branchName});
    return BranchError.BranchExist;
    
}

fn printBranches(branchesDir: *const std.fs.Dir) !void {
    var branchIter = branchesDir.iterate();
    while (branchIter.next() catch |err| {
        print("Zit branches iterator : {}\n", .{err});
        return;
    }) |folder| {
        std.debug.print("{s}\n", .{folder.name});
    }
}
