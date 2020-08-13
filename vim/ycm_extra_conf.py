
import os
import ycm_core

flags = [
    '-Wall',
    '-Wextra',
    '-Werror',
    '-fexceptions',
    '-DNDEBUG',
    '-std=c++11',
    '-x',
    'c++',
    '-isystem',
    '/usr/include',
    '-isystem',
    '/usr/local/include',
    '-isystem',
    '/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/../lib/c++/v1',
    '-isystem',
    '/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/include',
]


compilation_database_folder = ''

if os.path.exists(compilation_database_folder):
  database = ycm_core.CompilationDatabase(compilation_database_folder)
else:
  database = None

SOURCE_EXTENSIONS = ['.cpp', '.cxx', '.cc', '.c', '.m', '.mm']


def DirectoryOfThisScript():
  return os.path.dirname(os.path.abspath(__file__))


def IsHeaderFile(filename):
  extension = os.path.splitext(filename)[1]
  return extension in ['.h', '.hxx', '.hpp', '.hh']


def GetCompilationInfoForFile(filename):
  if IsHeaderFile(filename):
    basename = os.path.splitext(filename)[0]
    for extension in SOURCE_EXTENSIONS:
      replacement_file = basename + extension
      if os.path.exists(replacement_file):
        compilation_info = database.GetCompilationInfoForFile(
          replacement_file)
        if compilation_info.compiler_flags_:
          return compilation_info
    return None
  return database.GetCompilationInfoForFile(filename)


def FlagsForFile(filename, **kwargs):
  if not database:
    return {
      'flags': flags,
      'include_paths_relative_to_dir': DirectoryOfThisScript()
    }

  compilation_info = GetCompilationInfoForFile(filename)
  if not compilation_info:
    return None

  return {
    'flags': list(compilation_info.compiler_flags_),
    'include_paths_relative_to_dir': compilation_info.compiler_working_dir_
  }
