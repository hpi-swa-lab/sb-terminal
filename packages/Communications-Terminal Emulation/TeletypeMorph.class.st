"
I am a glass teletype.  I accept raw input from some source (which I display without interpretation) and generate raw characters for some sink.

I implement sufficient cursor addressing and character attributes to provide terminal emulators with the necessary support to implement ANSI (ISO 6429) colours and emphasis (with the exception of blinking) and the full range of VT220-style cursor-based screen editing.  However, I make no attempt to interpret ASCII control characters nor ANSI, DEC (or any other) escape sequences.  This, like all other `cooked' interpratation of special characters, is left entirely to my source and sink (which will normally be the same instance of some terminal emulator, immediately below me in a protocol stack).

I am designed to be the head of a protocol stack.  For this reason I expect my source to send me #upcall: aCharacter (I am the high protocol for some emulator) and I pass keyboard events down to my sink by sending it #downcall: aCharacter (the sink is my low protocol).  Anybody can send me #delete which I will propagate to all members of my protocol stack as a #windowClosed note.  (This will normally cause any connected endpoints at the tail end of the stack to be disconnected and destroyed.)

	TeletypeMorph new openInWorld

"
Class {
	#name : #TeletypeMorph,
	#superclass : #RectangleMorph,
	#instVars : [
		'inset',
		'font',
		'pitch',
		'skip',
		'rows',
		'cols',
		'lines',
		'savedLines',
		'savedLineLimit',
		'displayStart',
		'topLine',
		'bottomLine',
		'down',
		'x',
		'y',
		'fg',
		'bg',
		'em',
		'rv',
		'ec',
		'tabs',
		'useScrollbar',
		'scroll',
		'scrollFlop',
		'scrollRight',
		'scrollOn',
		'autoWrap',
		'reverseWrap',
		'autoLinefeed',
		'autoCR',
		'relativeOrigin',
		'insertMode',
		'showCursor',
		'session',
		'systemWindow',
		'running',
		'autoFlush',
		'smoothScroll',
		'steps',
		'metaSendsEscape',
		'deleteIsDel',
		'altScreenSwitch',
		'altScreenActive',
		'altScreenColours',
		'reverseVideo',
		'hasFocus',
		'mousePosition',
		'selectionStart',
		'selectionEnd',
		'selectionActive',
		'selection',
		'trackingSelection',
		'mouseControlsSelection',
		'keyboardControlsSelection',
		'scrollOnInput',
		'scrollOnOutput',
		'allow132',
		'characterClasses',
		'cursorColour'
	],
	#classVars : [
		'CharClass',
		'KeyboardControlsSelection',
		'MouseControlsSelection',
		'SaveTerminalSize',
		'SavedLineLimit',
		'TextCursor'
	],
	#category : #'Communications-Terminal Emulation'
}

{ #category : #examples }
TeletypeMorph class >> example [
	"TeletypeMorph example"

	| echo tty |
	"Pushing tty onto localEcho will convert ASCII control chars into tty cursor commands."
	(echo _ ProtocolAdaptor new) localEcho asProtocolStack push: (tty _ self new openInHand); install; run.
	echo downcallAll: TeletypeMorph organization classComment string asByteArray.
	tty activePosition: 1@24; flush.
	^tty
]

{ #category : #examples }
TeletypeMorph class >> example2 [
	"TeletypeMorph example2"

	| top tty |
	top _ ScrollPane new scroller: (tty _ TeletypeMorph new).
	ProtocolAdaptor new localEcho asProtocolStack push: tty; install; run.
	top openInHand
]

{ #category : #'class initialization' }
TeletypeMorph class >> initialize [
	"TeletypeMorph initialize"

	self initializeCursor.
	self initializeCharacterClasses.
	SavedLineLimit _ 64.
	"Set the default selection handling behaviour."
	MouseControlsSelection _ true.
	KeyboardControlsSelection _ false.
	"Notes:
	If MouseControlsSelection then selected text is copied to the clipboard when selection tracking finishes and the yellow button pastes from the clipboard into the terminal window.  Note that this moves the VT Options menu off the yellowButton and onto control-yellowButton (which is usually bound to the morph menu by things beyond our control; i.e., the VT menu becomes unavailable from within the TtyMorph itself.).
	If KeyboardControlsSelection then cmd-c copies the last mouse selection to the clipboard and cmd-v pastes the clipboard text into the terminal.  Note that this means M-C and M-V will no longer be available to programs such as Emacs.
	Note also that these can be in effect simultaneously to have both mouse and keyboard control of the selection.
	By default we turn mouse selection on and keyboard selection off.  This way the TtyMorph responds to the mouse like a real xterm and the M-C and M-V keys are passed unhindered to Emacs."
]

{ #category : #'class initialization' }
TeletypeMorph class >> initializeCharacterClasses [
	"TeletypeMorph initializeCharacterClasses asByteArray inspect"
	"Clicking the red button twice in rapid succession will cause all adjacent characters of the same class (e.g., letters, white space, punctuation) under the pointer to be selected.  Since different people have different preferences for what should be selected (for example, whether filenames should be selected as a whole or as individual path components) the default mapping can be overridden through the use of the CharClass variable.  The default collects whitespace, alphanumeric and special graphics characters into three classes.  Each punctuation character is in a class of its own.
	NOTE: in order to see the contents of some of the strings in this method you might have to select their contents and then use the window menu to change their font to Fixed."

	"Start with each character in its own class."
	CharClass _ (0 to: 255) asByteArray asString.
	"Put the ASCII whitespace characters (nul tab space) into the same class as space."
	#(0 9 32)
		do: [:c | CharClass at: 1 + c put: $ ].
	"Put the ASCII alphanumeric characters into the same class as `0'."
	'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz'
		do: [:c | CharClass at: 1 + c asciiValue put: $0].
	"Put the ISO 8859 Latin-1 accented characters into the same class as `0'."
	'ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿ'
		do: [:c | CharClass at: 1 + c asciiValue put: $0].
	"Put the ANSI special graphics characters into the same class as SOH (char 1)."
	'

'
		do: [:c | CharClass at: 1 + c asciiValue put: (Character value: 1)].
	"All other characters are punctuation and remain singletons."
	^CharClass


	"The table below is pulled directly out of xterm.  Evaluate the following to yield an Array whose first element is the complete set of xterm char classes and whose second element contains just the three non-singleton classes:
	| s |
	s _ IdentityDictionary new.
	#(32 1 1 1 1 1 1 1 1 32 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 32
	   33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 48 48 48 48 48 48 48
	   48 48 58 59 60 61 62 63 64 48 48 48 48 48 48 48 48 48 48 48 48 48 48
	   48 48 48 48 48 48 48 48 48 48 48 48 91 92 93 94 48 96 48 48 48 48 48
	   48 48 48 48 48 48 48 48 48 48 48 48 48 48 48 48 48 48 48 48 48 123 124
	   125 126 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
	   1 1 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175
	   176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 48 48
	   48 48 48 48 48 48 48 48 48 48 48 48 48 48 48 48 48 48 48 48 48 215 48
	   48 48 48 48 48 48 48 48 48 48 48 48 48 48 48 48 48 48 48 48 48 48 48
	   48 48 48 48 48 48 48 247 48 48 48 48 48 48 48 48)
		withIndexDo: [:e :i | (s at: e ifAbsent: [s at: e put: IdentitySet new]) add: i - 1].
	s _ s associationsDo: [:a | a value: a value asSortedCollection asByteArray].
	^Array with: s with: (s select: [:v | v size > 1])
"
]

{ #category : #'class initialization' }
TeletypeMorph class >> initializeCursor [
	"TeletypeMorph initializeCursor"
	"TextCursor showWhile: [Sensor waitButton]"

	TextCursor _   CursorWithMask derivedFrom:
		(Cursor
			extent: 16@16
			fromArray: #(
		2r0000000000000000
		2r0000111011100000
		2r0000001110000000
		2r0000000100000000
		2r0000000100000000
		2r0000000100000000
		2r0000000100000000
		2r0000000100000000
		2r0000000100000000
		2r0000000100000000
		2r0000000100000000
		2r0000000100000000
		2r0000001110000000
		2r0000111011100000
		2r0000000000000000
		2r0)
			offset: -7@-7).
]

{ #category : #'instance creation' }
TeletypeMorph class >> new [

	| tty |
	tty _ super new initialize: 80@24.
	^tty
]

{ #category : #'class initialization' }
TeletypeMorph class >> showCharacterClasses [
	"TeletypeMorph showCharacterClasses"

	| s range start stop |
	s _ IdentityDictionary new.
	CharClass asByteArray withIndexDo: [:e :i | (s at: e ifAbsent: [s at: e put: IdentitySet new]) add: i - 1].
	s _ (s associationsDo: [ :a | a value: a value asSortedCollection asByteArray]) select: [:v | v size > 1].
	s _ String streamContents: [ :str |
		s keys asSortedCollection do: [ :key |
			range _ ReadStream on: (s at: key).
			[range atEnd] whileFalse:
				[str nextPut: $,.start _ range next.
				 stop _ start.
				 [range atEnd not and: [stop + 1 == range peek]] whileTrue: [stop _ range next].
				 str nextPutAll: start printString.
				 start == stop ifFalse: [str nextPut: $-; nextPutAll: stop printString].
				 str nextPut: $:; nextPutAll: key printString]]].
	s _ s copyFrom: 2 to: s size.
	FillInTheBlank
		request: 'Character classes'
		initialAnswer: s
]

{ #category : #accessing }
TeletypeMorph >> activeColumn [

	^x
]

{ #category : #accessing }
TeletypeMorph >> activeColumn: c [

	x _ c min: cols.
	self showCursor.
]

{ #category : #'cursor control' }
TeletypeMorph >> activePosition [

	^x@y
]

{ #category : #'cursor control' }
TeletypeMorph >> activePosition: aPoint [

	self hideCursor.
	x _ aPoint x min: cols max: 1.
	y _ aPoint y min: rows max: 1.
	relativeOrigin ifTrue: [y _ y + topLine - 1 min: bottomLine max: topLine].
	self showCursor
]

{ #category : #private }
TeletypeMorph >> autoFlush [

	(autoFlush _ autoFlush - 1) < 1
		ifTrue:
			[self updateScrollbar; changed.
			 autoFlush _ self autoFlushCount.
			 Processor yield.]
]

{ #category : #private }
TeletypeMorph >> autoFlushCount [

	^smoothScroll ifTrue: [2] ifFalse: [rows]
]

{ #category : #private }
TeletypeMorph >> banner [

	^''
]

{ #category : #'cursor control' }
TeletypeMorph >> bs [

	self cursorLeft: 1 wrapping: false
]

{ #category : #accessing }
TeletypeMorph >> bufferState [
	"Answer an opaque representation of the current state of the buffer contents."

	| theLines state |
	self clearSelection.
	theLines _ OrderedCollection new.
	self linesDo: [:line | theLines addLast: line copy].
	state _ Array with: theLines asArray with: rv with: altScreenActive with: x with: y with: cursorColour.
	altScreenActive _ true.
	^state
]

{ #category : #accessing }
TeletypeMorph >> bufferState: state [
	"Restore the buffer contents to a previously saved state."

	| theLines nRows |
	altScreenSwitch ifFalse: [^self].
	self clearSelection; clearCursor.
	theLines _ state at: 1.
	rv _ state at: 2.
	altScreenActive _ state at: 3.
	"Ensure we have sufficient lines in the display."
	[lines size < theLines size]
		whileTrue:
			[lines addLast: (SimpleTextState new: cols).
			 self addMorphBack: (SimpleTextMorph contents: lines last)].
	nRows _ rows min: theLines size.
	1 to: nRows do: [ :i |
		(submorphs at: i)
			lineState:
			(self displayLineAt: i put:
				((theLines at: i) setWidth: cols))].
	nRows + 1 to: rows do: [:i | self clearLine: i from: 1 to: cols].
	submorphs from: 1 to: rows do: [ :m | m rv: (rv xor: reverseVideo)].
	x _ (state at: 4) min: cols max: 1.
	y _ (state at: 5) min: rows max: 1.
	cursorColour _ state at: 6.
	self showCursor; linesChanged; changed
]

{ #category : #menus }
TeletypeMorph >> buildMainMenu [

	| m |
	(m _ MenuMorph new) defaultTarget: self.
	m	add: 'redraw window' target: owner action: #changed;
			balloonTextForLastItem: 'Redisplay the contents of the window.';
		addLine.
	self
		menu: m add: 'meta sends escape' var: metaSendsEscape eval: [metaSendsEscape _ metaSendsEscape not]
			help: 'Send ESC before each keyboard character if the command key is pressed.';
		menu: m add: 'delete is del' var: deleteIsDel eval: [deleteIsDel _ deleteIsDel not]
			help: 'Send DEL instead of backspace.'.
	m addLine.
	m
		add: 'character classes ...' action: #menuSetCharacterClasses;
			balloonTextForLastItem: 'Modify the character classes used for double-click selection.'.
	self
		menu: m add: 'mouse controls clipboard' var: mouseControlsSelection eval: [mouseControlsSelection _ mouseControlsSelection not]
			help: 'If enabled then use xterm-style selection: selecting implies copy and the yellow button pastes.';
		menu: m add: 'keyboard controls clipboard' var: keyboardControlsSelection eval: [keyboardControlsSelection _ keyboardControlsSelection not]
			help: 'If enabled then use Squeak-style selection: cmd-c copies selection to clipboard and cmd-v pastes.'.
	m addLine.
	m
		add: 'saved line limit (', savedLineLimit printString, ') ...' action: #menuSetSavedLineLimit;
			balloonTextForLastItem: 'Set the maximum number of lines to save beyond the top of the window.'.
	m
		add: 'screen size (', cols printString, 'x', rows printString, ') ...' action: #menuResizeScreen;
			balloonTextForLastItem: 'Resize the screen to a given number of columns and rows.'.
	^m
]

{ #category : #menus }
TeletypeMorph >> buildVTMenu [

	| m |
	(m _ MenuMorph new) defaultTarget: self.

	self
		menu: m add: 'enable scrollbar' var: useScrollbar eval: [self menuToggleScrollbar]
			help: 'Show the scrollbar.';
		menu: m add: 'enable jump scroll' var: smoothScroll not eval: [smoothScroll _ smoothScroll not]
			help: 'Allow several lines to be displayed at once when input is arriving quickly.';
		menu: m add: 'enable reverse video' var: reverseVideo eval: [self setReverseVideo: reverseVideo not; flush]
			help: 'Display the entire window in reverse video.';
		menu: m add: 'enable auto wraparound' var: autoWrap eval: [autoWrap _ autoWrap not]
			help: 'Automatically wrap to the next line when the cursor reaches the last column.';
		menu: m add: 'enable reverse wraparound' var: reverseWrap eval: [reverseWrap _ reverseWrap not]
			help: 'Automaticaly wrap to the previous line when the cursor moves left of the first column.';
		menu: m add: 'enable auto linefeed' var: autoLinefeed eval: [autoLinefeed _ autoLinefeed not]
			help: 'Move to the next line automatically when carriage return is received.';

		menu: m add: 'scroll to bottom on key press' var: scrollOnInput eval: [scrollOnInput _ scrollOnInput not]
			help: 'Automatically reposition the screen to the bottom of the scrolling region when keyboard input is received.';
		menu: m add: 'scroll to bottom on tty output' var: scrollOnOutput eval: [scrollOnOutput _ scrollOnOutput not]
			help: 'Automatically reposition the screen to the bottom of the scrolling region when application output is received.';

		menu: m add: 'allow 80/132 column switching' var: allow132 eval: [allow132 _ allow132 not]
			help: 'Allow the program to resize the window automatically using 80/132 column escape sequences.';

		menu: m add: 'enable alternate screen switching' var: altScreenSwitch eval: [altScreenSwitch _ altScreenSwitch not]
			help: 'Allow switching to the alternate screen buffer.';
		menu: m add: 'enable alternate screen colours' var: altScreenColours eval: [self setAltScreenColours: altScreenColours not]
			help: self emacsColoursHelpString.
	m addLine;
		add: 'do soft reset' action: #doSoftReset;
			balloonTextForLastItem: 'Reset the scroll regions.  This can be convenient when some program has left the scroll regions set incorrectly (often a problem when using VMS or TOPS-20).';
		add: 'do full reset' action: #doFullReset;
			balloonTextForLastItem: 'Clear the screen, reset tabs to every eight columns, and reset the terminal modes (such as wrap and smooth scroll) to their initial states just after terminal initialisation.';
		add: 'reset and clear saved lines' action: #doResetAndClear;
			balloonTextForLastItem: 'Perform a full reset and then forget all lines scrolled off the top of the window.'.

	^m
]

{ #category : #accessing }
TeletypeMorph >> characterClass [

	^CharClass
]

{ #category : #'cursor control' }
TeletypeMorph >> clearCursor [

	lines do: [ :line | line cursorCol: 0]
]

{ #category : #'editor functions' }
TeletypeMorph >> clearLine [

	self
		hideCursor;
		clearLine: y from: 1 to: cols;
		showCursor
]

{ #category : #'editor functions' }
TeletypeMorph >> clearLine: n from: l to: r [

	(self lineAt: n)
		from: l to: r put: $  fg: fg bg: bg em: 0;
		lastColumn: l - 1.
]

{ #category : #'editor functions' }
TeletypeMorph >> clearLineLeft [

	self
		clearSelection;
		hideCursor;
		clearLine: y from: 1 to: x;
		showCursor
]

{ #category : #'editor functions' }
TeletypeMorph >> clearLineRight [

	self
		clearSelection;
		hideCursor;
		clearLine: y from: x to: cols;
		showCursor
]

{ #category : #'editor functions' }
TeletypeMorph >> clearScreen [

	self hideCursor.
	1 to: rows do: [:i | self clearLine: i from: 1 to: cols].
	self showCursor.
]

{ #category : #'editor functions' }
TeletypeMorph >> clearScreenLeft [

	self
		clearSelection;
		hideCursor;
		clearLine: y from: 1 to: x.
	1 to: y - 1 do: [:i | self clearLine: i from: 1 to: cols].
	self showCursor.
	self flush
]

{ #category : #'editor functions' }
TeletypeMorph >> clearScreenRight [

	self
		clearSelection;
		hideCursor;
		clearLine: y from: x to: cols.
	y + 1 to: rows do: [:i | self clearLine: i from: 1 to: cols].
	self showCursor.
	self flush
]

{ #category : #selection }
TeletypeMorph >> clearSelection [
	"Remove the visual representation of the selection region.  Saved selection text is unaffacted."

	selectionActive ifFalse: [^self].
	lines do: [:line | line clearSelection].
	selectionActive _ false.
	"self changed"
]

{ #category : #tabs }
TeletypeMorph >> clearTab [

	x <= cols ifTrue: [tabs at: x put: false].
"
	Transcript
		nextPutAll: 'tab CLR ', x printString; tab;
		nextPutAll: (String withAll: (tabs collect: [:t | t ifTrue: [$!] ifFalse: [$.]]));
		cr; endEntry
"
]

{ #category : #tabs }
TeletypeMorph >> clearTabs [

	tabs atAllPut: false.
]

{ #category : #accessing }
TeletypeMorph >> columns [

	^cols
]

{ #category : #selection }
TeletypeMorph >> copySelection [
	"Copy the currently selected text to the clipboard."

	Clipboard clipboardText: selection
]

{ #category : #'cursor control' }
TeletypeMorph >> cr [

	self hideCursor.
	x _ 1.
	self showCursor
]

{ #category : #private }
TeletypeMorph >> currentLine [

	^lines at: lines size - rows + y
]

{ #category : #'cursor control' }
TeletypeMorph >> cursorDown: n scrolling: scrollFlag [

	self hideCursor.
	n timesRepeat: [self cursorDownScrolling: scrollFlag].
	self showCursor
]

{ #category : #private }
TeletypeMorph >> cursorDownScrolling: scrollFlag [

	(y >= bottomLine and: [scrollFlag]) ifTrue: [self scrollForward].
	y _ y + 1 min: bottomLine
]

{ #category : #'cursor control' }
TeletypeMorph >> cursorLeft: n wrapping: wrapFlag [

	self hideCursor.
	n timesRepeat: [self cursorLeftWrapping: wrapFlag].
	self showCursor
]

{ #category : #private }
TeletypeMorph >> cursorLeftWrapping: wrapFlag [

	x > 1 ifTrue: [^x _ x - 1].
	(y > 1 and: [wrapFlag and: [reverseWrap]]) ifTrue: [x _ cols.  y _ y - 1]
]

{ #category : #'cursor control' }
TeletypeMorph >> cursorRight: n wrapping: wrapFlag [

	self hideCursor.
	n timesRepeat: [self cursorRightWrapping: wrapFlag].
	self showCursor
]

{ #category : #private }
TeletypeMorph >> cursorRightWrapping: wrapFlag [

	((x _ x + 1) > cols and: [wrapFlag not]) ifTrue: [x _ cols].
]

{ #category : #'cursor control' }
TeletypeMorph >> cursorUp: n scrolling: scrollFlag [

	self hideCursor.
	n timesRepeat: [self cursorUpScrolling: scrollFlag].
	self showCursor
]

{ #category : #private }
TeletypeMorph >> cursorUpScrolling: scrollFlag [

	(y <= topLine and: [scrollFlag]) ifTrue: [self scrollBackward].
	y _ y - 1 max: topLine
]

{ #category : #private }
TeletypeMorph >> debug: message [

	Transcript nextPutAll: message; cr; endEntry
]

{ #category : #private }
TeletypeMorph >> debug: message with: arg [

	Transcript nextPutAll: message; space; print: arg; cr; endEntry
]

{ #category : #private }
TeletypeMorph >> deleteForward [

	(self protectSelection; currentLine) deleteCharAt: x
]

{ #category : #'editor functions' }
TeletypeMorph >> deleteForward: n [

	self hideCursor.
	n timesRepeat: [self deleteForward].
	self showCursor
]

{ #category : #accessing }
TeletypeMorph >> deleteIsDel [

	^deleteIsDel
]

{ #category : #accessing }
TeletypeMorph >> deleteIsDel: aBoolean [

	deleteIsDel _ aBoolean
]

{ #category : #private }
TeletypeMorph >> deleteLine [

	^self scrollForwardFrom: y to: bottomLine
]

{ #category : #'editor functions' }
TeletypeMorph >> deleteLines: n [

	self hideCursor.
	n timesRepeat: [self deleteLine].
	self showCursor.
	self autoFlush
]

{ #category : #private }
TeletypeMorph >> displayLineAt: index [
	"Answer the displayed (visible) line at index."

	^lines at: displayStart + index
]

{ #category : #private }
TeletypeMorph >> displayLineAt: index put: anObject [
	"Change the displayed (visible) line at index."

	^lines at: displayStart + index put: anObject
]

{ #category : #private }
TeletypeMorph >> displayLinesDo: aBlock [

	lines from: displayStart + 1 to: displayStart + rows do: aBlock
]

{ #category : #'operating modes' }
TeletypeMorph >> doFullReset [
	"Clear the screen, reset tabs to every eight columns, and reset the terminal modes (such as wrap and smooth scroll) to their initial states just after terminal initialisation."

	self
		doSoftReset;
		clearSelection;
		clearScreen;
		activePosition: 1@1;
		initializeTabs;
		initializeTerminalModes;
		changed
]

{ #category : #'operating modes' }
TeletypeMorph >> doResetAndClear [
	"Reset the terminal to a sane state and clear the saved lines."

	self doFullReset.
	displayStart _ 0.
	savedLines _ 0.
	lines _ lines copyFrom: lines size - rows + 1 to: lines size.
	self linesChanged; changed
]

{ #category : #'operating modes' }
TeletypeMorph >> doSoftReset [
	"Reset scroll regions.  This can be convenient when some program has left the scroll regions set incorrectly (often a problem when using VMS or TOPS-20)."

	topLine _ 1.
	bottomLine _ rows.
]

{ #category : #protocol }
TeletypeMorph >> down: protoLo [

	down _ protoLo
]

{ #category : #private }
TeletypeMorph >> drawOn: aCanvas [

	super drawOn: aCanvas.
	self updateScrollbar.
]

{ #category : #private }
TeletypeMorph >> emacsColoursHelpString [
	"This is so long that it distracts from the menu building in progress."

	^'Use Emacs-style colours in the alternate screen buffer.

(Xterm has two independent screen buffers.  Programs such as "Emacs" and "less" run in the alternate buffer and switch back to the primary buffer when they exit -- hence preserving the original contents of the screen.  If this option is enabled then the alternate buffer will use a different colour scheme [similar to the one used by Emacs under X11] much better adapted to recent Emacsen [version 21 and higher] that are capable of using font-lock mode and colour highlighting when running in a terminal window.)'
]

{ #category : #selection }
TeletypeMorph >> endSelection: screenPosition [
	"Mouse selection has just finished.  Stop tracking and, iff the mouse moved since selection start, compute and remember the new selection text."

	self stopSteppingSelector: #trackSelection.
	self showCursor; changed.
	selectionEnd isNil ifTrue: [^nil].
	self saveSelection.
	screenPosition = mousePosition ifFalse: [selectionEnd _ nil]
]

{ #category : #selection }
TeletypeMorph >> extendSelection: screenPosition [
	"Extend the current selection through screenPosition."

	selectionStart isNil ifFalse: [self trackSelection: screenPosition]
]

{ #category : #geometry }
TeletypeMorph >> extent: newExtent [
	"We're being allocated real estate from above (initial placement or manual resize).  Adjust the screen size accordingly."

	| layoutBounds textBounds nCols nRows org ext lineSkip |
	super extent: newExtent.
	layoutBounds _ self layoutBounds.
	textBounds _ self textBounds: layoutBounds.
	nCols _ textBounds width // pitch.
	nRows _ textBounds height // skip.
	self hideScrollbar; initTextBounds: textBounds width: nCols height: nRows.
	org _ textBounds topLeft.
	ext _ (cols * pitch) @ skip.
	lineSkip _ 0 @ skip.
	submorphs doWithIndex: [:m :i |
		m bounds: (org extent: ext).
		org _ org translateBy: lineSkip].
	(useScrollbar and: [scrollFlop not]) ifTrue: [self showScrollbar].
]

{ #category : #'character writing' }
TeletypeMorph >> fillScreen: char [

	self
		clearSelection;
		linesDo: [:line | line atAllPut: char fg: fg bg: bg em: em]
]

{ #category : #protocol }
TeletypeMorph >> flush [

	submorphs from: 1 to: rows do: [ :m | m flush].
	autoFlush _ self autoFlushCount.
	self updateScrollbar.
]

{ #category : #selection }
TeletypeMorph >> getSelectionRegion [
	"Answer a Rectangle representing the current selection area in character coordinates.  Note that the origin may be to the right of the corner."

	| start end tmp |
	(start _ selectionStart) y > (end _ selectionEnd) y ifTrue: [start _ selectionEnd.  end _ selectionStart].
	(start y == end y and: [start x > end x]) ifTrue: [tmp _ start.  start _ end.  end _ tmp].
	"start now guaranteed to be before end in screen"
	"we don't include the character under selectionStart"
	end _ end - (1@0).
	^Rectangle origin: start corner: end
]

{ #category : #accessing }
TeletypeMorph >> graphicsState [
	"Answer an opaque representation of the current character attributes."

	^Array with: fg with: bg with: em with: rv
]

{ #category : #accessing }
TeletypeMorph >> graphicsState: gs [
	"Restore the current character attributes.  (See #graphicsState.)"

	fg _ gs at: 1.
	bg _ gs at: 2.
	em _ gs at: 3
]

{ #category : #events }
TeletypeMorph >> handlesKeyboard: evt [
	"Answer whether we're interested in keyboard events."

	^true "hasFocus or: [super handlesKeyboard: evt]"
]

{ #category : #events }
TeletypeMorph >> handlesMouseDown: evt [
	"Answer whether we're interested in mouse events."

	^true "self isConnected and: [hasFocus or: [super handlesMouseDown: evt]]"
]

{ #category : #events }
TeletypeMorph >> handlesMouseOver: evt [

	^true "hasFocus or: [super handlesMouseOver: evt]"
]

{ #category : #accessing }
TeletypeMorph >> hasFocus [

	^hasFocus
]

{ #category : #'cursor control' }
TeletypeMorph >> hideCursor [

	self currentLine cursorCol: 0
]

{ #category : #scrolling }
TeletypeMorph >> hideOrShowScrollBar [

	"ScrollBar sends us this for no good reason."
]

{ #category : #geometry }
TeletypeMorph >> hideScrollbar [
	"Remove the scrollbar from the window."

	scroll notNil
		ifTrue:
			[scroll delete.
			 scroll _ nil]
]

{ #category : #selection }
TeletypeMorph >> highlightSelection [
	"The selection region has changed.  Update the visual representation."

	| region |
	region _ self getSelectionRegion.
	lines do: [ :line | line clearSelection].
	region height == 0		"single line"
		ifTrue:
			[(lines at: region top) selectFrom: region left to: region right]
		ifFalse:
			[(lines at: region top) selectFrom: region left to: cols.
			 lines from: region top + 1 to: region bottom - 1 do: [:line | line selectFrom: 1 to: cols].
			 (lines at: region bottom) selectFrom: 1 to: region right].
	selectionActive _ true.
	self changed
]

{ #category : #geometry }
TeletypeMorph >> initScrollbar: frame [
	"Initialize the scrollbar to fit in/around the given frame."

	| width extent origin |
	width _ self scrollbarWidth.
	scrollFlop
		ifFalse:
			[extent _ (width) @ (frame height).
			 origin _ scrollRight
				ifFalse: [frame origin]
				ifTrue: [(frame right - width) @ (frame top)]]
		ifTrue:
			[extent _ (width + borderWidth) @ (frame height + (borderWidth * 2)).
			 origin _ scrollRight
				ifFalse: [(frame left - width - borderWidth) @ (frame top - borderWidth)]
				ifTrue: [(frame right) @ (frame top - borderWidth)]].
	scroll bounds: (origin extent: extent)
]

{ #category : #geometry }
TeletypeMorph >> initTextBounds: textBounds width: nCols height: nRows [
	"This is a geometry change imposed from outside (either initial placement or manual resizing).  We honour it without attempting to fix the geometry of our owner."

	| r morphs morph |
	(nCols == cols and: [nRows == rows]) ifTrue: [^self].
	morphs _ OrderedCollection withAll: submorphs.	"copy".
	self clearSelection; hideCursor; removeAllMorphs.
	cols _ nCols max: 1.
	x _ x min: cols.
	lines do: [ :line | line setWidth: cols].
	r _ nRows max: 1.
	[rows < r]
		whileTrue:
			[displayStart > 0
				ifTrue:
					["suck last saved line back down into the screen"
					 displayStart _ displayStart - 1.
					 savedLines _ savedLines - 1.
					 morphs addFirst: (SimpleTextMorph contents: (self displayLineAt: 1)).
					 y _ y + 1]
				ifFalse:
					["add a new empty line at the bottom of the screen"
					 morph _ SimpleTextMorph contents: (lines addLast: (SimpleTextState new: cols)).
					 morphs addLast: morph].
			 rows _ rows + 1].
	[rows > r]
		whileTrue:
			[rows _ rows - 1.
			 savedLines _ savedLines + 1.
			 displayStart _ displayStart + 1.
			 morphs removeLast.
			 y _ y - 1 max: 1].
	self
		addAllMorphs: morphs;
		showCursor;
		doSoftReset;
		initializeTabs;
		reportSizeToSession;
		linesChanged.
	"morphic explodes if we continue before making absolutely sure the window is redrawn..."
	"(running and: [self world notNil]) ifTrue: [self world doOneCycle]"
]

{ #category : #geometry }
TeletypeMorph >> initialExtent [

	self flag: #ikp. "can this can go away?"
	^self preferredExtent
]

{ #category : #'initialize-release' }
TeletypeMorph >> initialize [

	^self initialize: 80@24
]

{ #category : #'initialize-release' }
TeletypeMorph >> initialize: size [

	super initialize.
	borderWidth _ 2.
	color _ Color white.
	inset _ 2.
	trackingSelection _ false.
	useScrollbar _ false.
	self
		initializeTeletype: size;
		initializeContent;
		initializeScrollbar;
		extent: self preferredExtent
]

{ #category : #'initialize-release' }
TeletypeMorph >> initializeContent [

	| morphs |
	morphs _ OrderedCollection new.
	rows timesRepeat: [morphs addLast: ((SimpleTextMorph contents: (lines addLast: self newLine)) cursorColour: cursorColour)].
	self addAllMorphs: morphs.
	topLine _ 1.
	bottomLine _ rows.
	x _ y _ 1.
	self banner do: [:c | self upcall: c asInteger]
]

{ #category : #'initialize-release' }
TeletypeMorph >> initializeScrollbar [

	scrollFlop _ (Preferences valueOfFlag: #inboardScrollbars) not.
	scrollRight _ (Preferences valueOfFlag: #scrollBarsOnRight).
	useScrollbar & scrollFlop not ifTrue: [self showScrollbar]
]

{ #category : #'initialize-release' }
TeletypeMorph >> initializeTabs [

	tabs _ Array new: cols withAll: false.
	1 to: cols by: 8 do: [:i | tabs at: i put: true]
]

{ #category : #'initialize-release' }
TeletypeMorph >> initializeTeletype: size [
	"Initialize the default behaviour: dumb terminal with local echo and default xterm VT options."

	font _ TextStyle defaultFixedFont.
	pitch _ font widthOf: $m.
	skip _ font height.
	cols _ size x.  rows _ size y.
	lines _ OrderedCollection new.
	savedLines _ 0.
	savedLineLimit _ SavedLineLimit.
	displayStart _ 0.
	x _ 1.  y _ 1.
	fg _ 0.  bg _ 7.  em _ 0.
	rv _ false.  ec _ false.
	session _ nil.
	self initializeTabs.
	self initializeTerminalModes.
	"Default low protocol: local echo"
	down _ (ProtocolAdaptor new localEcho up: self).
	showCursor _ true.
	running _ false.
	autoFlush _ 0.
	steps _ 0.
	altScreenActive _ false.
	altScreenColours _ false.
	hasFocus _ true.
	selectionStart _ selectionEnd _ nil.
	selectionActive _ false.
	selection _ ''.
	mouseControlsSelection _ MouseControlsSelection.
	keyboardControlsSelection _ KeyboardControlsSelection.
	scrollOnInput _ false.
	scrollOnOutput _ true.
	allow132 _ true.
	characterClasses _ CharClass copy.
	cursorColour _ nil.
]

{ #category : #'initialize-release' }
TeletypeMorph >> initializeTerminalModes [
	"Initialize the default behaviour: dumb terminal with local echo and standard xterm VT option settings."

	autoWrap _ true.
	reverseWrap _ autoLinefeed _ autoCR _ relativeOrigin _ insertMode _ false.
	showCursor _ true.
	smoothScroll _ false.
	metaSendsEscape _ true.
	deleteIsDel _ false.
	altScreenSwitch _ true.
	reverseVideo _ false.
]

{ #category : #private }
TeletypeMorph >> insert [

	(self protectSelection; currentLine)
		at: x insert: $  fg: fg bg: bg em: em
]

{ #category : #'editor functions' }
TeletypeMorph >> insert: n [

	self hideCursor.
	n timesRepeat: [self insert].
	self showCursor
]

{ #category : #private }
TeletypeMorph >> insertLine [

	^self scrollBackwardFrom: y to: bottomLine
]

{ #category : #'editor functions' }
TeletypeMorph >> insertLines: n [

	self hideCursor.
	n timesRepeat: [self insertLine].
	self showCursor.
	self autoFlush
]

{ #category : #protocol }
TeletypeMorph >> install [

	session isNil ifFalse: [session propertyAt: #window put: self]
]

{ #category : #testing }
TeletypeMorph >> isCollapsed [

	^(systemWindow notNil) and: [systemWindow isCollapsed]
]

{ #category : #protocol }
TeletypeMorph >> isConnected [

	^session notNil and: [session isConnected]
]

{ #category : #events }
TeletypeMorph >> keyStroke: evt [
	"Receive a character from the keyboard."

	| char |
	scrollOnInput ifTrue: [self pageEnd].
	char _ evt keyCharacter asciiValue.
	evt controlKeyPressed
		ifFalse:
			[char == 1 ifTrue: [^self pageHome].
			 char == 4 ifTrue: [^self pageEnd].
			 char == 11 ifTrue: [^self pageUp: rows // 2].
			 char == 12 ifTrue: [^self pageDown: rows // 2]].
	(keyboardControlsSelection and: [evt commandKeyPressed])
		ifTrue:
			[evt keyCharacter == $c ifTrue: [^self copySelection].
			 evt keyCharacter == $v ifTrue: [^self sendSelection]].
	(metaSendsEscape and: [evt commandKeyPressed])
		ifTrue: [down downcall: Character escape asciiValue].
	"Cursor keys clash with control keys: differentiate by sending 128+cursorKeyCode."
	(char == 8 & deleteIsDel and: [evt controlKeyPressed not]) ifTrue: [char _ 127].
	(char < 32 and: [evt controlKeyPressed not]) ifTrue: [char _ char + 128].
	down downcall: char.
	evt wasHandled: true.
]

{ #category : #events }
TeletypeMorph >> keyboardFocusChange: aBoolean [

	hasFocus _ aBoolean
]

{ #category : #'cursor control' }
TeletypeMorph >> lf [

	autoCR
		ifTrue: [self newline]
		ifFalse: [self cursorDown: 1 scrolling: true]
]

{ #category : #private }
TeletypeMorph >> lineAt: index [

	^lines at: savedLines + index
]

{ #category : #private }
TeletypeMorph >> linesChanged [

	| lineNo line |
	lineNo _ displayStart.
	1 to: rows do: [ :i |
		line _ lines at: (lineNo _ lineNo + 1).
		line setWidth: cols.
		(submorphs at: i) lineState: line].
	1 to: rows do: [ :i | (submorphs at: i) rv: rv; cursorColour: cursorColour; ec: ec & altScreenColours].
	self autoFlush
]

{ #category : #private }
TeletypeMorph >> linesDo: aBlock [

	self linesFrom: 1 to: rows do: aBlock
]

{ #category : #private }
TeletypeMorph >> linesFrom: start to: stop do: aBlock [

	| first |
	first _ lines size - rows.
	lines from: first + start to: first + stop do: aBlock
]

{ #category : #private }
TeletypeMorph >> loadPreferences: dict [

	| r c s |
	(dict at: #saveTerminalMainOptions)
		ifTrue:
			[metaSendsEscape _ dict at: #metaSendsEscape.
			 deleteIsDel _ dict at: #deleteIsDel.
			 savedLineLimit _ dict at: #savedLineLimit.
			 characterClasses _ (dict at: #characterClasses) copy.
			 mouseControlsSelection _ dict at: #mouseControlsSelection.
			 keyboardControlsSelection _ dict at: #keyboardControlsSelection.
			 savedLineLimit _ dict at: #savedLineLimit].
	(dict at: #saveTerminalVTOptions)
		ifTrue:
			[s  _ dict at: #useScrollbar.
			 s == useScrollbar ifFalse: [self menuToggleScrollbar].
			 smoothScroll _ dict at: #smoothScroll.
			 reverseVideo _ dict at: #reverseVideo.
			 autoWrap _ dict at: #autoWrap.
			 reverseWrap _ dict at: #reverseWrap.
			 autoLinefeed _ dict at: #autoLinefeed.
			 autoCR _ dict at: #autoCR.
			 scrollOnInput _ dict at: #scrollOnInput.
			 scrollOnOutput _ dict at: #scrollOnOutput.
			 allow132 _ dict at: #allow132.
			 altScreenSwitch _ dict at: #altScreenSwitch.
			 altScreenColours _ dict at: #altScreenColours].
	(dict at: #saveTerminalSize)
		ifTrue:
			[r _ dict at: #rows.
			 c _ dict at: #cols.
			 (r == rows and: [c == cols]) ifFalse: [self setWidth: c height: r]]
]

{ #category : #events }
TeletypeMorph >> lock [
	"We're losing keyboard focus."

	super lock.
	hasFocus _ false.
	self changed.
]

{ #category : #menus }
TeletypeMorph >> menu: aMenu add: aString var: aBoolean eval: aBlock help: helpString [

	aMenu
		add: (aBoolean ifTrue: ['<yes>'] ifFalse: ['<no>']), aString
		selector: #menuBlock:
		argument: aBlock;
		balloonTextForLastItem: helpString
]

{ #category : #menus }
TeletypeMorph >> menuBlock: aBlock [

	aBlock value.
	self flush
]

{ #category : #menus }
TeletypeMorph >> menuResizeScreen [

	| n c r |
	n _ FillInTheBlank
		request: 'New screen size (columns x rows)?'
		initialAnswer: cols printString, 'x', rows printString.
	(n isNil or: [n isEmpty]) ifTrue: [^self].
	n _ n findTokens: 'x'.
	n size == 2 ifFalse: [^Smalltalk beep].
	(c _ n first asInteger) isNil ifTrue: [^Smalltalk beep].
	(r _ n last asInteger) isNil ifTrue: [^Smalltalk beep].
	self setWidth: c height: r
]

{ #category : #menus }
TeletypeMorph >> menuSetCharacterClasses [

	| n specs spec cclass range start stop |
	n _ FillInTheBlank request: 'Character classes?  (Enter ? for help.)' initialAnswer: '?'.
	(n isNil or: [n isEmpty]) ifTrue: [^self].
	n = '?' ifTrue: [^self menuSetCharacterClassesHelp].
	specs _ n findTokens: ','.
	specs do: [ :aSpec |
		Transcript cr; show: aSpec.
		start _ stop _ cclass _ nil.
		spec _ aSpec findTokens: ':'.
		Transcript cr; show: spec printString.
		spec size == 2
			ifTrue:
				[cclass _ spec last asInteger.
				 range _ spec first findTokens: '-'.
				 Transcript cr; show: range printString.
				 (cclass notNil and: [range size >= 1 and: [range size <= 2]])
					ifTrue:
						[start _ range first asInteger.
						 stop _ (range size == 2 ifTrue: [range last] ifFalse: [range first]) asInteger]].
		stop isNil ifTrue: [^Smalltalk beep; inform: 'Could not parse: ', spec printString].
		cclass _ Character value: cclass.
		characterClasses from: start + 1 to: stop + 1 put: cclass.].

	(self confirm: 'Would you like the current character classes  to be the default?')
		ifTrue: [CharClass _ characterClasses]

]

{ #category : #menus }
TeletypeMorph >> menuSetCharacterClassesHelp [

	StringHolder new
		contents: 'This preference is a series of comma-separated range:value pairs.  The range is either a single number or low-high in the range of 0 to 255, corresponding to the code for the character or characters to be set.  The value is the class in which to place the characters in the range.  The value is arbitrary, but the standard character classes use the following values: 1 for special graphics characters, 32 for whitespace, 48 for alphanumeric characters (letters and digits), and the code of the character itself for all others (corresponding to puncuation characters).

For example,

		33:48,37:48,45-47:48,64:48

indicates that the exclamation mark, percent sign, dash, period, slash, and ampersand characters should be treated the same way as letters and digits.  This is useful for copying and pasting electronic mailing addresses and filenames.  Also,

		33:48,37:48,45-47:48,58:48,64:48,126:48

is similar but includes colon and tilde, making most URLs selectable with a double click.';
		openLabel: 'Character Class Help'
]

{ #category : #menus }
TeletypeMorph >> menuSetSavedLineLimit [

	| n |
	n _ FillInTheBlank
		request: 'Saved line count?'
		initialAnswer: savedLineLimit printString.
	(n _ n asInteger) isNil ifTrue: [^self].
	savedLineLimit _ n.
	(self confirm: 'Would you like to make ', n printString, ' lines the default?')
		ifTrue: [SavedLineLimit _ n]
]

{ #category : #menus }
TeletypeMorph >> menuToggleScrollbar [

	| scrollWidth |
	self hideScrollbar.
	useScrollbar _ useScrollbar not.
	scrollWidth _ scrollFlop
		ifTrue: [0]
		ifFalse: [useScrollbar ifTrue: [self scrollbarWidth] ifFalse: [self scrollbarWidth negated]].
	self initializeScrollbar.
	systemWindow isNil
		ifTrue: [self extent: self extent + (scrollWidth @ 0)]
		ifFalse: [systemWindow extent: systemWindow extent + (scrollWidth @ 0)]
]

{ #category : #accessing }
TeletypeMorph >> metaSendsEscape [

	^metaSendsEscape
]

{ #category : #'operating modes' }
TeletypeMorph >> metaSendsEscape: aBoolean [

	metaSendsEscape _ aBoolean
]

{ #category : #events }
TeletypeMorph >> mouseDown: evt [
	"A mouse button has been pressed."

"	evt printString displayAt: 10@200.
"
	evt hand newKeyboardFocus: self.

	"Yellow button is menu (or selection send when in xterm mode)."
	(evt yellowButtonChanged)
		ifTrue:
			[(mouseControlsSelection and: [evt anyModifierKeyPressed not])
				ifTrue: [self sendSelection]
				ifFalse: [(systemWindow isKindOf: TeletypeWindow)
					ifTrue: [systemWindow offerWindowMenu]
					ifFalse: [self offerVTMenu]].
			 ^super mouseDown: evt].

	"Red button is selection start (or selection extend when shifted in Squeak mode)."
	(evt redButtonChanged)
		ifTrue:
			[evt shiftPressed
				ifTrue: ["mouseControlsSelection not and:" self extendSelection: evt position]
				ifFalse: [self startSelection: evt position].
			 ^super mouseDown: evt].

	"Blue button is selection extend when in xterm mode."
	(mouseControlsSelection and: [evt blueButtonChanged])
		ifTrue:
			[self extendSelection: evt position.
			 ^super mouseDown: evt].

	super mouseDown: evt.
]

{ #category : #events }
TeletypeMorph >> mouseEnter: evt [
	"The pointer just entered the window."

	TextCursor beCursor.
	useScrollbar & scrollFlop ifTrue: [self showScrollbar].
	super mouseEnter: evt
]

{ #category : #events }
TeletypeMorph >> mouseLeave: evt [
	"The cursor just left the window."

	Cursor normal show.
	useScrollbar & scrollFlop ifTrue: [self hideScrollbar].
	super mouseLeave: evt
]

{ #category : #events }
TeletypeMorph >> mouseMove: evt [
	"The mouse is moving inside the window."

"	evt printString displayAt: 10@220.
"
	evt redButtonPressed ifTrue: [self trackSelection: evt position].
	super mouseMove: evt
]

{ #category : #events }
TeletypeMorph >> mouseUp: evt [
	"A mouse button has been released."

"	evt printString displayAt: 10@240.
"
	evt redButtonChanged ifTrue: [self endSelection: evt position].
	evt wasHandled: true
]

{ #category : #private }
TeletypeMorph >> newLine [

	| line |
	line _ (SimpleTextState string: (String new: cols withAll: $ )) .
	ec & altScreenColours ifTrue: [line emacsColours].
	^line
]

{ #category : #'cursor control' }
TeletypeMorph >> newline [

	self hideCursor; cursorDown: 1 scrolling: true.
	x _ 1.
	self showCursor
]

{ #category : #protocol }
TeletypeMorph >> note: aSymbol with: anObject [

	aSymbol == #endpointClosed
		ifTrue:
			[^(systemWindow isKindOf: TeletypeWindow)
				ifTrue: [systemWindow endpointClosed]].

	aSymbol == #savePreferences ifTrue: [^self savePreferences: anObject].
	aSymbol == #loadPreferences ifTrue: [^self loadPreferences: anObject].
	aSymbol == #restoreDefaults ifTrue: 	[^self restoreDefaults]
]

{ #category : #menus }
TeletypeMorph >> offerVTMenu [
	"The user has pressed CTRL-Yellow (button 2).  Offer a menu similar to the Xterm `VT' menu."

	(self buildVTMenu addStayUpIcons title: 'VT Options')
		popUpEvent: self currentEvent in: self world
]

{ #category : #'initialize-release' }
TeletypeMorph >> openInWorld [

	self currentHand newKeyboardFocus: nil.
	super openInWorld.

]

{ #category : #scrolling }
TeletypeMorph >> pageDown: nLines [

	displayStart _ displayStart + nLines min: lines size - rows.
	self linesChanged; changed.
]

{ #category : #scrolling }
TeletypeMorph >> pageEnd [

	 lines size - rows == displayStart
		ifFalse:
		[displayStart _ lines size - rows.
		 self linesChanged; changed]
]

{ #category : #scrolling }
TeletypeMorph >> pageHome [

	displayStart _ 0.
	self linesChanged; changed.
]

{ #category : #scrolling }
TeletypeMorph >> pageUp: nLines [

	displayStart _ displayStart - nLines max: 0.
	self linesChanged; changed.
]

{ #category : #accessing }
TeletypeMorph >> pitch [

	^pitch
]

{ #category : #geometry }
TeletypeMorph >> preferredExtent [
	"Answer the extent that we would be given in an ideal world (no pun intended).  This is just the amout of space we need to display our contents, and no more."

	| w h s |
	s _ (useScrollbar and: [scrollFlop not]) ifTrue: [self scrollbarWidth] ifFalse: [0].
	w _ borderWidth + s + inset + (cols * pitch) + inset + borderWidth.
	h _ borderWidth + inset + (rows * skip) + inset + borderWidth.
	^w@h
]

{ #category : #private }
TeletypeMorph >> protectSelection [
	"If the active position is within the selected region, clear the selection."

	self flag: #ikp. "This is called way too often.  Need to go look where and when it's really necessary."
"
	'protect selection ', (TEMP _ TEMP + 1) printString, '  ' displayAt: 10@170.
"
	selectionActive ifTrue: [(self currentLine selectionSpansColumn: x) ifTrue: [self clearSelection]]
]

{ #category : #'character writing' }
TeletypeMorph >> put: aChar [

	scrollOnOutput ifTrue: [self pageEnd].
	(insertMode and: [x < cols]) ifTrue: [(self protectSelection; currentLine) insertAt: x].
	(aChar == 13 & autoLinefeed or: [aChar == 10 & autoCR])
		ifTrue: [self newline]
		ifFalse: [self putNormal: aChar; cursorRight: 1 wrapping: true]
]

{ #category : #'character writing' }
TeletypeMorph >> putNormal: aChar [

	x >= cols ifTrue: [self wrapIfPossible].
	selectionActive ifTrue: [self protectSelection].
	self currentLine at: x put: (Character value: aChar) fg: fg bg: bg em: em
]

{ #category : #private }
TeletypeMorph >> reportSizeToSession [

	session isNil ifFalse: [session note: #windowSize with: cols@rows]
]

{ #category : #'character writing' }
TeletypeMorph >> resetVideo [

	self
		clearSelection;
		setBackground: 7;
		setForeground: 0;
		setEmphasis: 0
]

{ #category : #private }
TeletypeMorph >> restoreDefaults [

	self initializeTerminalModes.
	savedLineLimit _ SavedLineLimit.
	altScreenColours ifTrue: [self setAltScreenColours: false].
	mouseControlsSelection _ true.
	keyboardControlsSelection _ false.
	scrollOnInput _ false.
	scrollOnOutput _ true.
	allow132 _ true.
	characterClasses _ CharClass copy.
	useScrollbar ifTrue: [self menuToggleScrollbar].
	(cols == 80 and: [rows == 24]) ifFalse: [self setWidth: 80 height: 24]
]

{ #category : #accessing }
TeletypeMorph >> rows [

	^rows
]

{ #category : #protocol }
TeletypeMorph >> run [

	running _ true.
	session isNil ifFalse: [session note: #windowSize with: cols@rows]
]

{ #category : #accessing }
TeletypeMorph >> rv: aBoolean [
	"Set the programmed reverse video flag.  Not to be confused with reverseVideo, which is a user preference that inverts the sense of the programmed change."

	rv == aBoolean ifTrue: [^self].
	rv _ aBoolean..
	submorphs from: 1 to: rows do: [ :m | m rv: (rv xor: reverseVideo)].
	self changed
]

{ #category : #private }
TeletypeMorph >> savePreferences: dict [

	dict
		at: #rows put: rows;
		at: #cols put: cols;
		at: #savedLineLimit put: savedLineLimit;
		at: #useScrollbar put: useScrollbar;
		at: #autoWrap put: autoWrap;
		at: #reverseWrap put: reverseWrap;
		at: #autoLinefeed put: autoLinefeed;
		at: #autoCR put: autoCR;
		at: #smoothScroll put: smoothScroll;
		at: #metaSendsEscape put: metaSendsEscape;
		at: #deleteIsDel put: deleteIsDel;
		at: #altScreenSwitch put: altScreenSwitch;
		at: #altScreenColours put: altScreenColours;
		at: #reverseVideo put: reverseVideo;
		at: #mouseControlsSelection put: mouseControlsSelection;
		at: #keyboardControlsSelection put: keyboardControlsSelection;
		at: #scrollOnInput put: scrollOnInput;
		at: #scrollOnOutput put: scrollOnOutput;
		at: #allow132 put: allow132;
		at: #characterClasses put: characterClasses copy
]

{ #category : #selection }
TeletypeMorph >> saveSelection [
	"A new selection has been made.  Compute and remember the selection text."

	| stream region |
	region _ self getSelectionRegion.
	stream _ WriteStream on: String new.
	lines from: region top to: region bottom do: [:line | line appendSelectionTo: stream].
	selection _ stream contents.
	mouseControlsSelection ifTrue: [Clipboard clipboardText: selection].
]

{ #category : #private }
TeletypeMorph >> scrollBackward [

	^self scrollBackwardFrom: topLine to: bottomLine
]

{ #category : #private }
TeletypeMorph >> scrollBackwardFrom: top to: bot [

	self hideCursor.
	savedLines + bot to: savedLines + top + 1 by: -1 do: [ :i | lines at: i put: (lines at: i - 1)].
	lines at: savedLines + top put: (SimpleTextState new: cols).
	self showCursor.
	self linesChanged
]

{ #category : #private }
TeletypeMorph >> scrollForward [

	^self scrollForwardFrom: topLine to: bottomLine
]

{ #category : #private }
TeletypeMorph >> scrollForwardFrom: top to: bot [

	self hideCursor.
	(top == 1 and: [bot == rows and: [altScreenActive not]])
		ifTrue:
			[lines addLast: (SimpleTextState new: cols).
			 lines size > (savedLineLimit + rows)
				ifTrue: [lines removeFirst selection notNil ifTrue: [self clearSelection]]
				ifFalse:
					[savedLines _ savedLines + 1.
					 displayStart _ displayStart + 1]]
		ifFalse:
			[savedLines + top to: savedLines + bot - 1 do: [ :i | lines at: i put: (lines at: i + 1)].
			 lines at: savedLines + bot put: (SimpleTextState new: cols)].
	self showCursor.
	self linesChanged; autoFlush
]

{ #category : #scrolling }
TeletypeMorph >> scrollbarMenuButtonPressed: evt [

	(systemWindow isKindOf: TeletypeWindow)
		ifTrue: [systemWindow offerWindowMenu]
		ifFalse: [self offerVTMenu]
]

{ #category : #scrolling }
TeletypeMorph >> scrollbarValue: value [

	| newStart |
	newStart _ (savedLines * value) rounded min: lines size - rows.
	newStart == displayStart ifTrue: [^self].
	displayStart _ newStart.
	self linesChanged; changed
]

{ #category : #geometry }
TeletypeMorph >> scrollbarWidth [

	^ScrollPane new scrollbarWidth
]

{ #category : #selection }
TeletypeMorph >> selectLine: screenPosition [
	"Triple click.  Select the line surrounding the cursor, including the end of line, and save the selection text."

	| pos |
"
	'select line   ' displayAt: 10@130.
"
	pos _ self selectionPositionAt: screenPosition.
	selectionStart _ 1 @ pos y.
	selectionEnd _ cols + 1 @ pos y.
	self highlightSelection; saveSelection.
	selectionEnd _ nil.
	mousePosition _ nil.
]

{ #category : #selection }
TeletypeMorph >> selectWord: screenPosition [
	"Double click.  Select the word surrounding the cursor according to the current char class and save the selection text."

	| pos line left right |
"
	'select word   ' displayAt: 10@130.
"
	pos _ self selectionPositionAt: screenPosition.
	line _ lines at: pos y.
	left _ line findFirstInClass: self characterClass from: (pos x min: cols).
	right _ line findLastInClass: self characterClass from: (pos x min: cols).
	selectionStart _ left @ pos y.
	selectionEnd _ right + 1 @ pos y.
	right < left
		ifTrue: [self clearSelection]
		ifFalse: [self highlightSelection; saveSelection]
]

{ #category : #selection }
TeletypeMorph >> selectionPositionAt: screenPosition [
	"Answer a Point in character coordinates corresponding to the given position in screen coordinates.  If screenPosition is above the window, try to scroll up before answering the first character in the window.  If screenPosition is below the window, try to scroll down before answering one character right of the last character in the window."

	| pos |
	screenPosition y < (self submorphs at: 1) bounds top
		ifTrue:
			[self pageUp: (rows // 8 max: 1).
			 ^1 @ (displayStart + 1)].
	screenPosition y > (self submorphs at: rows) bounds bottom
		ifTrue:
			[self pageDown: (rows // 8 max: 1).
			 ^(cols + 1) @ (displayStart + rows)].
	1 to: rows do: [:i
		| (pos _ (self submorphs at: i) selectionColumnAt: screenPosition) isNil
			ifFalse: [^pos @ (displayStart + i)]].
	^nil
]

{ #category : #selection }
TeletypeMorph >> sendSelection [
	"Send the clipboard text to the application."

	down downcallAll: Clipboard clipboardText asString asByteArray
]

{ #category : #protocol }
TeletypeMorph >> session [

	^session
]

{ #category : #'initialize-release' }
TeletypeMorph >> session: aSession [

	session _ aSession
]

{ #category : #protocol }
TeletypeMorph >> sessionNote: aSymbol [

	self sessionNote: aSymbol with: nil
]

{ #category : #protocol }
TeletypeMorph >> sessionNote: aSymbol with: anObject [

	session isNil ifFalse: [session note: aSymbol with: anObject]
]

{ #category : #'operating modes' }
TeletypeMorph >> setAltScreenColours: aBoolean [

	altScreenColours _ aBoolean.
	self setEmacsColours: ec.
]

{ #category : #'operating modes' }
TeletypeMorph >> setAutoLinefeed: aBoolean [

	autoLinefeed _ aBoolean
]

{ #category : #'operating modes' }
TeletypeMorph >> setAutoWrap: aBoolean [

	autoWrap _ aBoolean
]

{ #category : #'character writing' }
TeletypeMorph >> setBackground: index [

	bg _ index min: 7 max: 0.
]

{ #category : #'operating modes' }
TeletypeMorph >> setEmacsColours: aBoolean [

	(ec _ aBoolean) & altScreenColours
		ifTrue: [submorphs from: 1 to: rows do: [:line | line emacsColours]]
		ifFalse: [submorphs from: 1 to: rows do: [:line | line normalColours]].
	self changed
]

{ #category : #'character writing' }
TeletypeMorph >> setEmphasis: index [

	index == 0 ifTrue: [^em _ 0].
	em _ em bitOr: (1 bitShift: index - 1).
]

{ #category : #'character writing' }
TeletypeMorph >> setEmphasis: index to: bit [

	bit == 0
		ifTrue: [em _ em bitClear: (1 bitShift: index - 1)]
		ifFalse: [em _ em bitOr: (1 bitShift: index - 1)]
]

{ #category : #'character writing' }
TeletypeMorph >> setForeground: index [

	fg _ index min: 7 max: 0
]

{ #category : #'operating modes' }
TeletypeMorph >> setIconTitle: aString [

	systemWindow notNil
		ifTrue:
			[(systemWindow isKindOf: TeletypeWindow)
				ifTrue: [systemWindow setIconTitle: aString]]
				"icon title ignored by other kinds of window"
]

{ #category : #'operating modes' }
TeletypeMorph >> setInsertMode: aBoolean [

	insertMode _ aBoolean
]

{ #category : #'operating modes' }
TeletypeMorph >> setRelativeOrigin: aBoolean [

	relativeOrigin _ aBoolean.
	self activePosition: 1@1
]

{ #category : #'operating modes' }
TeletypeMorph >> setReverseVideo: aBoolean [

	reverseVideo == aBoolean ifTrue: [^self].
	reverseVideo _ aBoolean.
	submorphs from: 1 to: rows do: [ :m | m rv: (rv xor: reverseVideo)].
	self changed
]

{ #category : #'operating modes' }
TeletypeMorph >> setScrollRegionTop: top bottom: bottom [

	topLine _ top min: rows - 1 max: 1.
	bottomLine _ bottom min: rows max: top + 1
]

{ #category : #'operating modes' }
TeletypeMorph >> setShowCursor: aBoolean [

	self hideCursor.
	showCursor _ aBoolean.
	self showCursor
]

{ #category : #'operating modes' }
TeletypeMorph >> setSmoothScroll: aBoolean [

	autoFlush _ 0.
	smoothScroll _ aBoolean
]

{ #category : #tabs }
TeletypeMorph >> setTab [

	x <= cols ifTrue: [tabs at: x put: true].
"
	Transcript
		nextPutAll: 'tab SET ', x printString; tab;
		nextPutAll: (String withAll: (tabs collect: [:t | t ifTrue: [$!] ifFalse: [$.]]));
		cr; endEntry
"
]

{ #category : #'operating modes' }
TeletypeMorph >> setWidth: nCols [

	allow132 ifTrue: [self setWidth: nCols height: rows]
]

{ #category : #geometry }
TeletypeMorph >> setWidth: nCols height: nRows [
	"This is a programmed geometry change.  We try to honour it by figuring out the corresponding geometry change required in our owner in order to acheive the given number of cols and rows.  The actual change takes place on the flip side, when our owner sends down our new extent."

	| flak |
	(cols == nCols and: [rows == nRows]) ifTrue: [^self].
	flak _ systemWindow isNil ifTrue: [0] ifFalse: [systemWindow fullBounds extent - self textBounds extent].
	"self changed; sync."
	(systemWindow isNil ifTrue: [self] ifFalse: [systemWindow])
		extent: (pitch * nCols) @ (skip * nRows) + flak.
	"self sync."
]

{ #category : #'initialize-release' }
TeletypeMorph >> setWindow: aWindow [

	systemWindow _ aWindow
]

{ #category : #'operating modes' }
TeletypeMorph >> setWindowTitle: aString [

	systemWindow notNil
		ifTrue:
			[(systemWindow isKindOf: TeletypeWindow)
				ifTrue: [systemWindow setWindowTitle: aString]
				ifFalse: [systemWindow setLabel: aString]]
]

{ #category : #'cursor control' }
TeletypeMorph >> showCursor [

	self currentLine cursorCol: x
]

{ #category : #geometry }
TeletypeMorph >> showScrollbar [
	"Add a scrollbar to the window."

	scroll isNil
		ifTrue:
			[scroll _ ScrollBar new model: self slotName: 'scrollbar'; initializeEmbedded: scrollFlop not.
			 self
				addMorphBack: scroll;
				initScrollbar: self layoutBounds;
				updateScrollbar]
]

{ #category : #accessing }
TeletypeMorph >> skip [

	^skip
]

{ #category : #selection }
TeletypeMorph >> startSelection: screenPosition [
	"Mouse selection has begun.  If this is a double click (mouse hasn't moved since last click and selectionEnd isNil) then select the word under the pointer.  If this is a triple click (mouse hasn't moved and selectionEnd notNil after prior word selection) then select the line under the pointer.  Otherwise clear the current selectionStart and begin tracking."

	| start |
	self hideCursor; changed.
	mousePosition = screenPosition
		ifTrue:
			[^selectionEnd isNil
				ifTrue: [self selectWord: screenPosition]
				ifFalse: [self selectLine: screenPosition]].
"
	'mouse position ' , mousePosition printString,
	' screen position ', screenPosition printString, 
	' selectionEnd ', selectionEnd printString, 
	'  ' displayAt: 10@150.
"
	mousePosition _ screenPosition.
	selectionEnd _ nil.

	start _ self selectionPositionAt: screenPosition.
	self clearSelection.
	selectionStart _ start.
"
	'selection begin ', selectionStart printString, '     ' displayAt: 10@10
"
]

{ #category : #private }
TeletypeMorph >> step [

	steps _ steps + 1
]

{ #category : #private }
TeletypeMorph >> sync [
	"Wait until the world has revolved at least once before proceeding."

	| s |
	s _ steps + 1.
	[steps < s] whileTrue: [^Processor yield]
]

{ #category : #tabs }
TeletypeMorph >> tab [

	self hideCursor.
	[x _ x + 1.
	 x < cols and: [(tabs at: x) not]]
		whileTrue.
	x _ x min: cols.
	self showCursor.
]

{ #category : #geometry }
TeletypeMorph >> textBounds [
	"Answer just the bounds of the text -- excluding border, scroll and inset."

	^self textBounds: self layoutBounds
]

{ #category : #geometry }
TeletypeMorph >> textBounds: outer [
	"Answer just the bounds of the text -- excluding border, scroll and inset."

	| width left right inner |
	left _ right _ 0.
	(useScrollbar & scrollFlop not)
		ifTrue:
			[width _ self scrollbarWidth.
			 scrollRight ifTrue: [right _ width] ifFalse: [left _ width]].
	inner _ outer insetBy: inset.
	^(inner left + left) @ (inner top) corner: (inner right - right) @ (inner bottom)
]

{ #category : #selection }
TeletypeMorph >> trackSelection [
	"The mouse is down during selection tracking.  Update the visual representation of the selected region."

	| pos |
	(pos _ self selectionPositionAt: Sensor cursorPoint) isNil
		ifFalse:
			[selectionEnd _ pos.
			 self highlightSelection]
]

{ #category : #selection }
TeletypeMorph >> trackSelection: screenPosition [
	"The mouse moved during selection tracking.  Update the visual representation of the selected region."

	(trackingSelection or: [(self selectionPositionAt: screenPosition) isNil])
		ifFalse: [self
				startStepping: #trackSelection
				at: Time millisecondClockValue
				arguments: #()
				stepTime: 100]
]

{ #category : #events }
TeletypeMorph >> unlock [
	"We're acquiring keyboard focus."

	super unlock.
	hasFocus _ true.
	self changed.
]

{ #category : #protocol }
TeletypeMorph >> upcall: char [
"
	Transcript show: 'upcall ', char printString; cr.
""	char printString , '   ' displayAt: 10@10.
"
	self put: char
]

{ #category : #protocol }
TeletypeMorph >> upcallAll: aCollection [

	aCollection do: [:b | self upcall: b]
]

{ #category : #scrolling }
TeletypeMorph >> updateScrollbar [

	scroll isNil ifTrue: [^self].
	savedLines == 0 ifTrue: [^scroll interval: 1.0; setValue: 0].
	scroll
		scrollDelta: (1 / savedLines) asFloat
		pageDelta: (rows / savedLines) asFloat;
		interval: (rows / lines size) asFloat;
		setValue: (displayStart / savedLines) asFloat
]

{ #category : #events }
TeletypeMorph >> wouldAcceptKeyboardFocus [
	"Of course we would."

	^true
]

{ #category : #private }
TeletypeMorph >> wrapIfPossible [

	x > cols ifTrue: [autoWrap
		ifTrue: [x _ 1.  self cursorDown: 1 scrolling: true]
		ifFalse: [x _ cols]]
]
