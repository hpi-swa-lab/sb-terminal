Class {
	#name : #SBBashEditor,
	#superclass : #SBBrowserEditor,
	#instVars : [
		'synopsisBlock',
		'descriptionBlock',
		'debugBlock'
	],
	#category : #SBBash
}

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
SBBashEditor >> initialize [

	| sidebarScroll |
	super initialize.
	
	self width: 80 * 8 + (250 + 50).
	self openMorph: (SBBashTerminal new
		hResizing: #spaceFill;
		vResizing: #spaceFill).
	
	self submorphs second addMorphBack: (sidebarScroll := ScrollPane new
		hResizing: #shrinkWrap;
		vResizing: #spaceFill).
	sidebarScroll scroller
		addMorphBack: (SBColumn new
			addMorphBack: (synopsisBlock := SBBashFormattedTextBubble multiLine
				placeholderText: 'No synopsis found';
				focusable: false;
				maxWidth: 250);
			addMorphBack: (debugBlock := SBBashFormattedTextBubble multiLine
				placeholderText: 'No debugoutput found';
				focusable: false);
			addMorphBack: (descriptionBlock := SBBashFormattedTextBubble multiLine
				placeholderText: 'No description found';
				focusable: false;
				maxWidth: 250));
		layoutInset: 8.
	
	inputMapping useSuggestionViaCr: false
	"maxWidth: 250""maxWidth: 250"
]

{ #category : #'as yet unclassified' }
SBBashEditor >> insertCommandRequest: aMorph near: aBlock before: aBoolean [

	^ nil
]

{ #category : #'as yet unclassified' }
SBBashEditor >> synopsisBlock [

	^ synopsisBlock
]
