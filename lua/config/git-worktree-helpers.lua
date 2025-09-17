-- lua/git-worktree-helpers.lua
local M = {}
local Hooks = require("git-worktree.hooks")
local Worktree = require("git-worktree")
local Job = require("plenary.job")

local function sh(cmd, opts)
    return Job:new(vim.tbl_extend("force", { command = "bash", args = { "-lc", cmd } }, opts or {})):sync()
end

local function git(cmd, cwd) return sh("git " .. cmd, { cwd = cwd }) end
local function git_common_dir() return vim.fn.systemlist("git rev-parse --git-common-dir")[1] end
local function repo_base() return vim.fn.fnamemodify(git_common_dir(), ":h") end
local function sanitize_branch(b) return (b:gsub("/", "_"):gsub("[^%w%._-]", "-")) end
local function path_for(branch) return repo_base() .. "/" .. sanitize_branch(branch) end
local function sesh_connect(path) vim.fn.jobstart({ "sesh_connect_and_rename", path}, { detach = true }) end

-- Hook: whenever we switch/create, also switch tmux session via sesh
function M.enable_sesh_hooks()
    Hooks.register(Hooks.type.SWITCH, function(path, prev_path)
        local repo_branch = path:match("([^/]+/[^/]+)$") or vim.fn.fnamemodify(path, ":t")
        sesh_connect(repo_branch)
    end)
end


-- Always refresh refs first
local function preflight_fetch(cwd) git("fetch --prune --tags", cwd) end

local function has_local_branch(b)
  return os.execute(("git show-ref --verify --quiet refs/heads/%s >/dev/null 2>&1"):format(b)) == 0
end
local function has_remote_branch(remote, b)
  return os.execute(("git ls-remote --exit-code --heads %s %s >/dev/null 2>&1"):format(remote, b)) == 0
end
local function resolve_base_ref(base, remote)
  if has_local_branch(base) then return base end
  if base:match("^%w+/.+") then return base end -- e.g. origin/main, upstream/dev
  if has_remote_branch(remote, base) then return ("%s/%s"):format(remote, base) end
  return base -- allow tag or commit SHA
end



-- Create worktree as a sibling to .git:  <repo>/<branch-name>
-- ensure a switch after create so SWITCH hook fires (and sesh connects)
function M.create(branch, upstream)
    upstream = upstream or "origin"
    preflight_fetch()
    local p = path_for(branch)
    Worktree.create_worktree(p, branch, upstream)
    Worktree.switch_worktree(p) -- trigger SWITCH (and sesh)
end

-- Switch by branch or absolute path; always fetch first
function M.switch(branch_or_path)
    preflight_fetch()
    local p = vim.fn.isdirectory(branch_or_path) == 1 and branch_or_path or path_for(branch_or_path)
    Worktree.switch_worktree(p)
    -- sesh switch via hook
end

-- Delete worktree folder + prune admin files
function M.delete(branch_or_path, force)
    preflight_fetch()
    local p = vim.fn.isdirectory(branch_or_path) == 1 and branch_or_path or path_for(branch_or_path)
    Worktree.delete_worktree(p, force or false)
    git("worktree prune") -- clean stale entries
end

-- Delete worktree + (optionally) remote branch, with confirmation
function M.delete_with_remote(branch, remote)
    remote = remote or "origin"
    branch = branch or vim.fn.systemlist("git symbolic-ref --short HEAD")[1]
    local p = path_for(branch)
    local prompt = ("Delete worktree:\n  %s\nand delete remote branch: %s/%s ?"):format(p, remote, branch)
    vim.ui.select({ "No", "Yes" }, { prompt = prompt }, function(choice)
        if choice ~= "Yes" then return end
        preflight_fetch()
        Worktree.delete_worktree(p, true) -- force remove folder if needed
        -- delete remote branch if it exists
        local ok = (os.execute(("git ls-remote --exit-code --heads %s %s >/dev/null 2>&1"):format(remote, branch)) == 0)
        if ok then git(("push %s --delete %s"):format(remote, branch)) end
        -- delete local branch if no other worktree uses it
        local lines = git("worktree list --porcelain")
        local still_used = vim.iter(lines):any(function(l) return l:find("branch refs/heads/" .. branch, 1, true) end)
        if not still_used then git(("branch -D %s"):format(branch)) end
        git("worktree prune")
    end)
end


-- create a new branch from a base ref, add worktree, then switch (sesh hook fires)
function M.create_branch_from(base, new_branch, remote)
  remote = remote or "origin"
  preflight_fetch()
  local base_ref = resolve_base_ref(base, remote)
  local dir = path_for(new_branch)                       -- repo/<new_branch> sibling to .git
  sh(("git worktree add -b %s %s %s")
      :format(new_branch, vim.fn.shellescape(dir), base_ref))
  require("git-worktree").switch_worktree(dir)           -- triggers SWITCH hook → sesh connect
end



-- Determine default base branch, preferring origin/main then origin/master
local function default_base_remote(remote)
    remote = remote or "origin"
    preflight_fetch()
    if has_remote_branch(remote, "main") then return ("%s/%s"):format(remote, "main") end
    if has_remote_branch(remote, "master") then return ("%s/%s"):format(remote, "master") end
    return ("%s/%s"):format(remote, "main")
end

M.default_base = default_base_remote

return M
