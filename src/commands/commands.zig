pub const COMMAND_TYPE = enum {
    init,
    branch,
    NA

};

pub const init = @import("init.zig").init;
pub const branch = @import("branch.zig").branch;



