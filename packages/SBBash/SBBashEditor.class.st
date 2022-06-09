Class {
	#name : #SBBashEditor,
	#superclass : #SBBrowserEditor,
	#instVars : [
		'synopsisBlock'
	],
	#category : #SBBash
}

{ #category : #'as yet unclassified' }
SBBashEditor >> initialize [

	super initialize.
	
	self openMorphInView: (SBBashTerminal new
		hResizing: #spaceFill;
		vResizing: #spaceFill).
	
	self submorphs second addMorphBack: (synopsisBlock := SBBashFormattedTextBubble multiLine
		placeholderText: 'No synopsis found';
		focusable: false)
]

{ #category : #'as yet unclassified' }
SBBashEditor >> synopsisBlock [

	^ synopsisBlock
]
