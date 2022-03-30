# Sandblocks Terminal
An in-progress implementation of a terminal interface making use of [Sandblocks](https://github.com/hpi-swa-lab/sb-terminal) for display.

## Setup
Pre-built PseudoTTYPlugin (step 2) is compiled only for linux-amd64. You can compile your own via the [opensmalltalk-vm](https://github.com/OpenSmalltalk/opensmalltalk-vm/) repo.

1. Download and extract [http://files.squeak.org/trunk/Squeak6.0alpha-21486-64bit/Squeak6.0alpha-21486-64bit-202112201228-Linux-x64.tar.gz]()
2. Copy `sb-bash/bin/PseudoTTYPlugin.so` to `bin/` of your extracted squeak-trunk folder
3. Run squeak, then run in a workspace:
```smalltalk
Metacello new
  baseline: 'SBTreeSitter';
  repository: 'github://hpi-swa-lab/sb-tree-sitter:master/packages';
  get; load.
```
4. Click "Tools > Git", wait for it to install
5. Add new project, select sb-terminal, right-click newest commit, "checkout objects". (when it asks to fix the font, click no)
6. Run
```smalltalk
SBEditor open openMorphInView: (SBStPlayground newFromSource: 'SBBashPrompt new open')
```
7. Run the line in the sandblocks workspace, enjoy a bash!

## Acknowledgements
This project bundles the termimal emulator and pseudo tty implementation for Squeak by Ian Piumarta [originally published here](http://squeakvm.org/unix/goodies.html), used with permission.
