#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include <CoreServices/CoreServices.h>


// Structure for storing metadata parsed from the commandline
static struct {
  FSEventStreamEventId        sinceWhen;
  CFTimeInterval              latency;
  FSEventStreamCreateFlags    flags;
  CFMutableArrayRef           paths;
} config = {
  (UInt64) kFSEventStreamEventIdSinceNow,
  (double) 0.3,
  (UInt32) kFSEventStreamCreateFlagNone,
  NULL
};

// Prototypes
static void         append_path(const char *path);
static inline void  parse_cli_settings(int argc, const char *argv[]);
static void         callback(FSEventStreamRef streamRef,
                             void *clientCallBackInfo,
                             size_t numEvents,
                             void *eventPaths,
                             const FSEventStreamEventFlags eventFlags[],
                             const FSEventStreamEventId eventIds[]);


// Resolve a path and append it to the CLI settings structure
// The FSEvents API will, internally, resolve paths using a similar scheme.
// Performing this ahead of time makes things less confusing, IMHO.
static void append_path(const char *path)
{
#ifdef DEBUG
  fprintf(stderr, "\n");
  fprintf(stderr, "append_path called for: %s\n", path);
#endif

  char fullPath[PATH_MAX];

  if (realpath(path, fullPath) == NULL) {
#ifdef DEBUG
    fprintf(stderr, "  realpath not directly resolvable from path\n");
#endif

    if (path[0] != '/') {
#ifdef DEBUG
      fprintf(stderr, "  passed path is not absolute\n");
#endif
      size_t len;
      getcwd(fullPath, sizeof(fullPath));
#ifdef DEBUG
      fprintf(stderr, "  result of getcwd: %s\n", fullPath);
#endif
      len = strlen(fullPath);
      fullPath[len] = '/';
      strlcpy(&fullPath[len + 1], path, sizeof(fullPath) - (len + 1));
    } else {
#ifdef DEBUG
      fprintf(stderr, "  assuming path does not YET exist\n");
#endif
      strlcpy(fullPath, path, sizeof(fullPath));
    }
  }

#ifdef DEBUG
  fprintf(stderr, "  resolved path to: %s\n", fullPath);
  fprintf(stderr, "\n");
  fflush(stderr);
#endif

  CFStringRef pathRef = CFStringCreateWithCString(kCFAllocatorDefault,
                                                  fullPath,
                                                  kCFStringEncodingUTF8);
  CFArrayAppendValue(config.paths, pathRef);
  CFRelease(pathRef);
}

// Parse commandline settings
static inline void parse_cli_settings(int argc, const char *argv[])
{
  config.paths = CFArrayCreateMutable(NULL,
                                      (CFIndex)0,
                                      &kCFTypeArrayCallBacks);

  for (int i = 1; i < argc; i++) {
    if (strcmp(argv[i], "--since-when") == 0) {
      config.sinceWhen = strtoull(argv[++i], NULL, 0);
    } else if (strcmp(argv[i], "--latency") == 0) {
      config.latency = strtod(argv[++i], NULL);
    } else if (strcmp(argv[i], "--no-defer") == 0) {
      config.flags |= kFSEventStreamCreateFlagNoDefer;
    } else if (strcmp(argv[i], "--watch-root") == 0) {
      config.flags |= kFSEventStreamCreateFlagWatchRoot;
    } else if (strcmp(argv[i], "--ignore-self") == 0) {
#if MAC_OS_X_VERSION_MAX_ALLOWED >= 1060
      config.flags |= kFSEventStreamCreateFlagIgnoreSelf;
#else
      fprintf(stderr, "MacOSX10.6.sdk is required for --ignore-self\n");
#endif
    } else {
      append_path(argv[i]);
    }
  }

  if (CFArrayGetCount(config.paths) == 0) {
    append_path(".");
  }

#ifdef DEBUG
  fprintf(stderr, "config.sinceWhen    %llu\n", config.sinceWhen);
  fprintf(stderr, "config.latency      %f\n", config.latency);
  fprintf(stderr, "config.flags        %#.8x\n", config.flags);
  fprintf(stderr, "config.paths\n");

  long numpaths = CFArrayGetCount(config.paths);

  for (long i = 0; i < numpaths; i++) {
    char path[PATH_MAX];
    CFStringGetCString(CFArrayGetValueAtIndex(config.paths, i),
                       path,
                       PATH_MAX,
                       kCFStringEncodingUTF8);
    fprintf(stderr, "  %s\n", path);
  }

  fprintf(stderr, "\n");
  fflush(stderr);
#endif
}

static void callback(FSEventStreamRef streamRef,
                     void *clientCallBackInfo,
                     size_t numEvents,
                     void *eventPaths,
                     const FSEventStreamEventFlags eventFlags[],
                     const FSEventStreamEventId eventIds[])
{
  char **paths = eventPaths;

#ifdef DEBUG
  fprintf(stderr, "\n");
  fprintf(stderr, "FSEventStreamCallback fired!\n");
  fprintf(stderr, "  numEvents: %lu\n", numEvents);

  for (size_t i = 0; i < numEvents; i++) {
    fprintf(stderr, "  event path: %s\n", paths[i]);
    fprintf(stderr, "  event flags: %#.8x\n", eventFlags[i]);
    fprintf(stderr, "  event ID: %llu\n", eventIds[i]);
  }

  fprintf(stderr, "\n");
  fflush(stderr);
#endif

  for (size_t i = 0; i < numEvents; i++) {
    fprintf(stdout, "%s", paths[i]);
    fprintf(stdout, ":");
  }

  fprintf(stdout, "\n");
  fflush(stdout);
}

int main(int argc, const char *argv[])
{
  /*
   * a subprocess will initially inherit the process group of its parent. the
   * process group may have a control terminal associated with it, which would
   * be the first tty device opened by the group leader. typically the group
   * leader is your shell and the control terminal is your login device. a
   * subset of signals triggered on the control terminal are sent to all members
   * of the process group, in large part to facilitate sane and consistent
   * cleanup (ex: control terminal was closed).
   *
   * so why the overly descriptive lecture style comment?
   *   1. SIGINT and SIGQUIT are among the signals with this behavior
   *   2. a number of applications gank the above for their own use
   *   3. ruby's insanely useful "guard" is one of these applications
   *   4. despite having some level of understanding of POSIX signals and a few
   *      of the scenarios that might cause problems, i learned this one only
   *      after reading ruby 1.9's process.c
   *   5. if left completely undocumented, even slightly obscure bugfixes
   *      may be removed as cruft by a future maintainer
   *
   * hindsight is 20/20 addition: if you're single-threaded and blocking on IO
   * with a subprocess, then handlers for deferrable signals might not get run
   * when you expect them to. In the case of Ruby 1.8, that means making use of
   * IO::select, which will preserve correct signal handling behavior.
   */
  if (setpgid(0,0) < 0) {
    fprintf(stderr, "Unable to set new process group.\n");
    return 1;
  }

  parse_cli_settings(argc, argv);

  FSEventStreamContext context = {0, NULL, NULL, NULL, NULL};
  FSEventStreamRef stream;
  stream = FSEventStreamCreate(kCFAllocatorDefault,
                               (FSEventStreamCallback)&callback,
                               &context,
                               config.paths,
                               config.sinceWhen,
                               config.latency,
                               config.flags);

#ifdef DEBUG
  FSEventStreamShow(stream);
  fprintf(stderr, "\n");
  fflush(stderr);
#endif

  FSEventStreamScheduleWithRunLoop(stream,
                                   CFRunLoopGetCurrent(),
                                   kCFRunLoopDefaultMode);
  FSEventStreamStart(stream);
  CFRunLoopRun();
  FSEventStreamFlushSync(stream);
  FSEventStreamStop(stream);

  return 0;
}
