{
  stdenv,
  fetchFromGitHub,
  lib,
  ...
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "netns-exec";
  version = "aa346fd058d47b238ae1b86250f414bcab2e7927";
  src = fetchFromGitHub {
    owner = "pekman";
    repo = "netns-exec";
    rev = "aa346fd058d47b238ae1b86250f414bcab2e7927";
    fetchSubmodules = true;
    hash = "sha256-CnIgzRb58KIvdx7T9LpervSB2Ol6JMxmSM/Ti3K1+Dg=";
  };

  postPatch = ''
    # netns_switch() has already unshared the mount namespace and made mounts
    # rslave. Mask host NSS sockets/caches there before dropping privileges.
    substituteInPlace netns-exec.c \
      --replace-fail '#include "namespace.h"' ${lib.escapeShellArg ''
        #include "namespace.h"
        #include <fcntl.h>
        #include <sys/mount.h>

        static int isolate_host_nscd(void)
        {
            static const char *const paths[] = {
                "/run/nscd",
                "/var/db/nscd",
                "/var/cache/nscd",
            };

            for (size_t i = 0; i < sizeof(paths) / sizeof(paths[0]); i++) {
                /* Fixed paths only; refuse symlinks and pin the target against
                 * renames while mounting. Never create directories on the host. */
                int fd = open(paths[i], O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC);
                if (fd < 0) {
                    if (errno == ENOENT)
                        continue;
                    perror(paths[i]);
                    return -1;
                }

                char target[64];
                snprintf(target, sizeof(target), "/proc/self/fd/%d", fd);
                int r = mount("tmpfs", target, "tmpfs",
                              MS_RDONLY | MS_NOSUID | MS_NODEV | MS_NOEXEC,
                              "mode=0555,size=4k");
                int saved_errno = errno;
                close(fd);
                if (r < 0) {
                    errno = saved_errno;
                    perror(paths[i]);
                    return -1;
                }
            }
            return 0;
        }
      ''} \
      --replace-fail '    drop_root_privileges();' ${lib.escapeShellArg ''
        if (isolate_host_nscd() < 0)
            return EXIT_OTHER_ERROR;

        drop_root_privileges();
      ''}

    substituteInPlace Makefile \
      --replace-fail "-m4755" "-m755"

    # Force use sched func from libc
    substituteInPlace iproute2/configure \
      --replace-fail '$CC -I$INCLUDE -o $TMPDIR/setnstest $TMPDIR/setnstest.c' "true"
  '';

  installFlags = [ "PREFIX=${placeholder "out"}" ];

  meta = {
    description = "Run command in Linux network namespace as normal user";
    homepage = "https://github.com/pekman/netns-exec";
    license = lib.licenses.gpl2Only;
    mainProgram = "netns-exec";
  };
})
