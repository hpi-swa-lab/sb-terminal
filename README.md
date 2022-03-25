# Setup
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
5. Add new project, select sb-bash, right-click newest commit, "checkout objects". (when it asks to fix the font, click no)
6. Run
```smalltalk
SBEditor open openMorphInView: (SBStPlayground newFromSource: 'SBBashPrompt new open')
```
7. Run the line in the sandblocks workspace, enjoy a bash!
