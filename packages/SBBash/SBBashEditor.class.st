Class {
	#name : #SBBashEditor,
	#superclass : #SBBrowserEditor,
	#instVars : [
		'synopsisBlock',
		'descriptionBlock',
		'debugBlock',
		'terminal',
		'synopsisCaption',
		'descriptionCaption',
		'examplesCaption',
		'examplesBlock'
	],
	#category : #SBBash
}

{ #category : #'as yet unclassified' }
SBBashEditor class >> newBash [

	^ self basicNew initializeWithoutSidebar
]

{ #category : #'as yet unclassified' }
SBBashEditor class >> pathToAllManpageData [

	^ self pathToManpageScripts, '../temp.data'
]

{ #category : #'as yet unclassified' }
SBBashEditor class >> pathToManpageCompletionScript [

	^ self pathToManpageScripts, 'create_manpage_completions.py'
]

{ #category : #'as yet unclassified' }
SBBashEditor class >> pathToManpageNameScript [

	^ self pathToManpageScripts, 'get_manpage_names.py'
]

{ #category : #'as yet unclassified' }
SBBashEditor class >> pathToManpageScripts [

	^ '../manpages/manpage_completions/'
]

{ #category : #'as yet unclassified' }
SBBashEditor class >> pathToManpages [

	^ '/usr/share/man/man1/'
]

{ #category : #'as yet unclassified' }
SBBashEditor class >> registerShortcuts: aProvider [

	aProvider registerShortcut: Character tab do: #autocompleteFile
]

{ #category : #'as yet unclassified' }
SBBashEditor >> debugBlock [

	^ debugBlock
]

{ #category : #'as yet unclassified' }
SBBashEditor >> descriptionBlock [

	^ descriptionBlock
]

{ #category : #'as yet unclassified' }
SBBashEditor >> examplesBlock [

	^ examplesBlock
]

{ #category : #'as yet unclassified' }
SBBashEditor >> initialize [

	| sidebarScroll sidebarWidth |
	super initialize.
	
	sidebarWidth := 370.
	self width: 80 * 8 + (sidebarWidth + 50).
	self openMorph: (terminal := SBBashTerminal new
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		bashMode: false).
	
	self submorphs second addMorphBack: (sidebarScroll := ScrollPane new
		hResizing: #shrinkWrap;
		vResizing: #spaceFill).
	sidebarScroll scroller addMorphBack: (SBColumn new
		addMorphBack: (synopsisCaption := SBTextBubble new contents: 'Synopsis:');
		addMorphBack: (synopsisBlock := SBBashFormattedTextBubble multiLine
			placeholderText: 'No synopsis found';
			focusable: false;
			maxWidth: sidebarWidth;
			minWidth: sidebarWidth);
		addMorphBack: (examplesCaption := SBTextBubble new contents: 'Examples:');
		addMorphBack: (examplesBlock := SBBashFormattedTextBubble multiLine
			placeholderText: 'No examples found';
			focusable: false;
			maxWidth: sidebarWidth;
			minWidth: sidebarWidth);
		addMorphBack: (descriptionCaption := SBTextBubble new contents: 'Description:');
		addMorphBack: (descriptionBlock := SBBashFormattedTextBubble multiLine
			placeholderText: 'No description found';
			focusable: false;
			maxWidth: sidebarWidth;
			minWidth: sidebarWidth);
		layoutInset: 4;
		cellGap: 4).
	
	debugBlock := SBBashFormattedTextBubble multiLine
		placeholderText: 'Nothing';
		focusable: false;
		maxWidth: sidebarWidth.
	
	inputMapping useSuggestionViaCr: false
]

{ #category : #'as yet unclassified' }
SBBashEditor >> initializeWithoutSidebar [

	| sidebarWidth |
	super initialize.
	
	self width: 80 * 10.
	self openMorph: (terminal := SBBashTerminal new
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		bashMode: true).
	
	SBColumn new
		addMorphBack: (synopsisCaption := SBTextBubble new contents: 'Synopsis:');
		addMorphBack: (synopsisBlock := SBBashFormattedTextBubble multiLine
			placeholderText: 'No synopsis found';
			focusable: false;
			maxWidth: sidebarWidth;
			minWidth: sidebarWidth);
		addMorphBack: (examplesCaption := SBTextBubble new contents: 'Examples:');
		addMorphBack: (examplesBlock := SBBashFormattedTextBubble multiLine
			placeholderText: 'No examples found';
			focusable: false;
			maxWidth: sidebarWidth;
			minWidth: sidebarWidth);
		addMorphBack: (descriptionCaption := SBTextBubble new contents: 'Description:');
		addMorphBack: (descriptionBlock := SBBashFormattedTextBubble multiLine
			placeholderText: 'No description found';
			focusable: false;
			maxWidth: sidebarWidth;
			minWidth: sidebarWidth);
		layoutInset: 4;
		cellGap: 4.
	
	debugBlock := SBBashFormattedTextBubble multiLine
		placeholderText: 'Nothing';
		focusable: false;
		maxWidth: sidebarWidth.
	
	inputMapping useSuggestionViaCr: false
]

{ #category : #'as yet unclassified' }
SBBashEditor >> insertCommandRequest: aMorph near: aBlock before: aBoolean [

	^ nil
]

{ #category : #'as yet unclassified' }
SBBashEditor >> performShortcutFor: anEvent [
	"auch bei backspace?"
	"anEvent key isCharacter and:"

	SBToggledCode comment: '' active: 0 do: {
		[(anEvent key isCharacter and: [anEvent key isLetter or: [anEvent key isDigit]]) ifTrue: [terminal currentCommandBlock commandString: terminal newestCommandBlock input]]}.
	
	terminal currentCommandBlock commandString: terminal newestCommandBlock input.
	^ super performShortcutFor: anEvent
]

{ #category : #'as yet unclassified' }
SBBashEditor >> synopsisBlock [

	^ synopsisBlock
]

{ #category : #'as yet unclassified' }
SBBashEditor >> synopsisCaption [

	^ synopsisCaption
]
