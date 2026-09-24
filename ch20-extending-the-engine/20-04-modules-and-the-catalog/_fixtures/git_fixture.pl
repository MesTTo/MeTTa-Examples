% Purpose: build a throwaway local git repository holding one MeTTa library,
%   so the git-import! example acquires a real repository without reaching a
%   network. The suite ran on every push and cloned github each time.
% Assumes:
%   - git is on PATH, which git-import! already requires
%     [source: lib/lib_gitimport/lib_gitimport.pl, git_process/5]
%   - mkdir and rm are on PATH as well, and make and clear the fixture's
%     directories
%   - every process that runs the example runs it once and then exits, which
%     is how tools/test.sh, the twins lane and the pytest example items run it
% Guarantees:
%   - the path it answers is a git repository whose HEAD holds fixture.metta,
%     and no earlier checkout of it survives the call
%     [tested: examples/ch20-extending-the-engine/20-04-modules-and-the-catalog/06-git_import.metta]
%   - two processes building the fixture under one base never interleave: the
%     second waits until the first has exited, so a run never reads a checkout
%     another run is deleting
%     [tested 2026-09-25T05:07:33+10:00: tests/shell/test_git_import_example_serializes.sh]
%   - a call costs the same inferences whether an earlier run left its
%     directories behind or not, so the example's twin pins one count
%     [measured 2026-09-25T05:07:21+10:00: 34,218 with the directories
%     absent and 34,218 present, one fresh process a reading;
%     command=python extensions/python/tools/twin_coverage.py --measure
%     --rounds 1]
% Fails when: a process keeps running after the example, a notebook kernel
%   say, since it holds the lock until it exits and every other run under that
%   base waits for it.
% Owns: <Base>/.sources/metta_fixture_lib and <Base>/metta_fixture_lib, both
%   deleted and rebuilt per call, and the lock file
%   <Base>/.sources/metta_fixture_lib.lock. Nothing else may keep files there.
% Guarded by: an fcntl write lock on <Base>/.sources/metta_fixture_lib.lock,
%   taken before anything is deleted and held until the process exits.
% Open Obligations:
%   To Do: None
%   Hacks: None
%   Future Enhancements: None

:- use_module(library(filesex)).
:- use_module(library(process)).

git_fixture_name(metta_fixture_lib).

%Function-form convention, so MeTTa imports this as a one-argument function:
%the base directory goes in, the clone URL comes out.
%
%Both the source and any checkout of it are rebuilt, because git-import!
%does not fetch into a checkout that already exists: leaving one behind
%would silently serve a stale library after this fixture changed.
%
%mkdir and rm work in child processes, as git does, so the example costs the
%same whatever an earlier run left there. delete_directory_and_contents/1
%walks the tree in Prolog, so a run that found a finished run's directories
%paid 1,484 more than one that found none [measured
%2026-09-25T05:06:54+10:00: 33,122 absent against 34,606
%present, one fresh process each; command=python
%extensions/python/tools/twin_coverage.py --measure --rounds 1]; and
%make_directory_path/1 charged 15 more for creating the
%directories than for finding them [measured 2026-09-25T05:07:09+10:00:
%33,965 absent against 33,950 present, this fixture
%with make_directory_path/1 in place of the child mkdir].
git_fixture_url(Base0, Url) :-
    git_fixture_atom(Base0, Base),
    git_fixture_name(Name),
    directory_file_path(Base, '.sources', SourceRoot),
    directory_file_path(SourceRoot, Name, SourceDir),
    directory_file_path(Base, Name, CloneDir),
    git_fixture_run(mkdir, '.', ['-p', '--', SourceRoot]),
    git_fixture_hold(SourceDir),
    git_fixture_run(rm, '.', ['-rf', '--', SourceDir, CloneDir]),
    make_directory(SourceDir),
    git_fixture_write_library(SourceDir),
    git_fixture_commit(SourceDir),
    absolute_file_name(SourceDir, Url, [file_type(directory)]).

%Every process that runs this example in one tree shares both directories,
%and one gate runs it in three lanes at once: engine/check.sh's shell and
%examples lanes each run the whole corpus, and the twins lane runs
%06-git_import.py. A run that deleted them while another was building or
%importing failed that other run, its commit exiting 1 with nothing to
%commit or its init exiting 128. So a run takes this lock before deleting
%anything and holds it until it exits, which is when its checkout stops being
%read.
%
%open/4 waits in fcntl(F_SETLKW), so waiting spends no inferences and the
%twin's count does not depend on which run went first [source
%2026-09-25T05:06:53+10:00: swipl-devel V10.1.14 src/os/pl-stream.c, the lock branch
%of Sopen_file]. The stream is
%kept in a global variable named by the lock file, so atom garbage collection
%cannot close it and a second call in the same process neither opens the file
%again nor drops the first stream: closing any descriptor of a file drops every
%POSIX lock the process holds on it. For the same reason this is not
%git-import!'s own <Base>/metta_fixture_lib.lock, which git-import! closes as
%soon as the clone is done, before the import reads the checkout.
git_fixture_hold(SourceDir) :-
    atom_concat(SourceDir, '.lock', LockFile),
    (   nb_current(LockFile, _)
    ->  true
    ;   open(LockFile, append, Held, [lock(write)]),
        nb_setval(LockFile, Held)
    ).

git_fixture_atom(Value, Atom) :- atom(Value), !, Atom = Value.
git_fixture_atom(Value, Atom) :- atom_string(Atom, Value).

git_fixture_write_library(Dir) :-
    directory_file_path(Dir, 'fixture.metta', Library),
    setup_call_cleanup(
        open(Library, write, Stream),
        format(Stream, "(= (fixture-answer $x) (* $x 3))~n", []),
        close(Stream)).

%An explicit identity, because a machine with no git user configured would
%otherwise fail the commit rather than the test it is meant to support.
git_fixture_commit(Dir) :-
    git_fixture_run(git, Dir, [init, '-q']),
    git_fixture_run(git, Dir, [add, 'fixture.metta']),
    git_fixture_run(git, Dir, ['-c', 'user.email=fixture@metta.invalid',
                               '-c', 'user.name=metta fixture',
                               commit, '-q', '-m', 'fixture library']).

git_fixture_run(Program, Dir, Arguments) :-
    setup_call_cleanup(
        process_create(path(Program), Arguments,
                       [cwd(Dir), stdout(null), stderr(pipe(Error)),
                        process(PID)]),
        read_string(Error, _, Diagnostic),
        close(Error)),
    process_wait(PID, Status),
    ( Status == exit(0)
      -> true
    ; throw(error(metta_git_fixture_failed([Program|Arguments], Status,
                                           Diagnostic),
                  context(git_fixture_run/3,
                          'could not build the local git fixture'))) ).
