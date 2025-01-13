pub const COMMAND_TYPE = enum {
    init,
    branch,
    change,
    NA

};

pub const com_init = @import("init.zig").com_init;
pub const com_branch = @import("branch.zig").com_branch;
pub const com_change = @import("change.zig").com_change;


pub const branch_create = @import("branch.zig").createBranch;
pub const change_branch = @import("change.zig").changeBranch;

pub const MAIN_BRANCH = "main";

pub const ZIT_DIR = ".zit";
pub const ZIT_HEAD_DIR = ".zit/head";
pub const ZIT_COMMITS_DIR = ".zit/commits";
pub const ZIT_BRANCHES_DIR = ".zit/branches";
pub const ZIT_OBJ_DIR = ".zit/obj";


pub const HEAD_DIR = "head";
pub const COMMITS_DIR = "commits";
pub const BRANCHES_DIR = "branches";
pub const OBJ_DIR = "obj";


pub const HEAD_CURRENT_FI = "head/current";

pub const CURRENT_FI = "current";



