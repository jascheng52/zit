const std = @import("std");
const print = std.debug.print;

const BranchOptions = enum {
    create,
    delete,
    NA,
};

pub fn branch(args: *std.process.ArgIterator) void {
    var cwd = std.fs.cwd();
    const zitDir = cwd.openDir(".zit", .{}) catch {
        print("Zit not initialized\n", .{});
        return;
    };
    const branchesDir = zitDir.openDir("branches", .{ .iterate = true }) catch {
        print("Zit branches dir missing", .{});
        return;
    };

    _ = &cwd;

    const commandArg = args.next();
    if (commandArg == null) {
        try printBranches(&branchesDir);
        return;
    }

    const commandSwitch = std.meta.stringToEnum(BranchOptions,commandArg.?) orelse BranchOptions.NA;
    switch (commandSwitch) 
    {
        BranchOptions.create => create(args, &branchesDir),
        BranchOptions.delete => delete(args, &branchesDir),
        else => invalid(),
    }
    

}

fn create(args: *std.process.ArgIterator, branchDir: *const std.fs.Dir) void
{
    const branchName = args.next();
    if (branchName == null) {
        print("Missing branch name \n", .{});
        return;
    }
    createBranch(branchName.?, branchDir);

    return;
}

fn delete(args: *std.process.ArgIterator, branchDir: *const std.fs.Dir) void
{
    const branchName = args.next();
    if (branchName == null) {
        print("Missing branch name \n", .{});
        return;
    }

    deleteBranch(branchName.?, branchDir);
}

fn invalid() void
{
    print("Invalid options\n", .{});
    return;
}

fn createBranch(branchName: []const u8, branchDir: *const std.fs.Dir) void {
    _ = branchDir.openDir(branchName, .{}) catch {

        _ = branchDir.makeDir(branchName) catch  {
            print("Failed to make branch {s}", .{branchName});
        };
        print("Branch:{s} created\n", .{branchName});
        return;
        
    };
    print("Branch {s} already exists\n", .{branchName});
    return;
    
}

fn deleteBranch(branchName: []const u8, branchDir: *const std.fs.Dir) void 
{
    var branchIter = branchDir.iterate();
    while (branchIter.next() catch |err| {
        print("Zit branches iterator : {}\n", .{err});
        return;
    }) |folder| 
    {
        if(std.mem.eql( u8, folder.name, branchName) )
        {
            branchDir.deleteTree(branchName) catch {
                print("Failed to delete branch:{s}", .{branchName});
                return;
            };
            print("Branch:{s} deleted\n", .{branchName});

            return;
        }
    }
    print("Branch:{s} does not exist\n", .{branchName});
    return;
}

fn printBranches(branchDir: *const std.fs.Dir) !void {
    var branchIter = branchDir.iterate();
    while (branchIter.next() catch |err| {
        print("Zit branches iterator : {}\n", .{err});
        return;
    }) |folder| 
    {
        std.debug.print("{s}\n", .{folder.name});
    }
}
