Class {
	#name : #SBBashEditor,
	#superclass : #SBBrowserEditor,
	#instVars : [
		'synopsisBlock',
		'argumentsBlock',
		'descriptionBlock'
	],
	#category : #SBBash
}

{ #category : #'as yet unclassified' }
SBBashEditor class >> registerShortcuts: aProvider [

	aProvider registerShortcut: Character tab do: #autocompleteFile
]

{ #category : #'as yet unclassified' }
SBBashEditor >> descriptionBlock [

	^ descriptionBlock
]

{ #category : #'as yet unclassified' }
SBBashEditor >> initialize [

	super initialize.
	
	self openMorphInView: (SBBashTerminal new
		hResizing: #spaceFill;
		vResizing: #spaceFill).
	
	self submorphs second addMorphBack: (SBBlock new
		addMorphBack: (synopsisBlock := SBBashFormattedTextBubble multiLine
			placeholderText: 'No synopsis found';
			focusable: false;
			maxWidth: 200);
		addMorphBack: (argumentsBlock := SBBashFormattedTextBubble multiLine
			placeholderText: 'No arguments found';
			focusable: false);
		addMorphBack: (descriptionBlock := SBBashFormattedTextBubble multiLine
			placeholderText: 'No description found';
			focusable: false;
			maxWidth: 200);
		changeTableLayout;
		listDirection: #topToBottom)
]

{ #category : #'as yet unclassified' }
SBBashEditor >> synopsisBlock [

	^ synopsisBlock
]
