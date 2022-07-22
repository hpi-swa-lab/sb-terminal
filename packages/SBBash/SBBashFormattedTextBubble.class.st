Class {
	#name : #SBBashFormattedTextBubble,
	#superclass : #SBTextBubble,
	#instVars : [
		'focusable'
	],
	#category : #SBBash
}

{ #category : #'as yet unclassified' }
SBBashFormattedTextBubble >> click: anEvent [

	focusable ifTrue: [super click: anEvent] ifFalse: [
		(self parentSandblock isKindOf: SBBashCommandBlock) ifTrue: [self parentSandblock focus]]
]

{ #category : #'as yet unclassified' }
SBBashFormattedTextBubble >> contents: aString [

	self assert: aString notNil.
	super contents: aString
]

{ #category : #'as yet unclassified' }
SBBashFormattedTextBubble >> currentTextMorph [

	^ self focusable ifTrue: [super currentTextMorph] ifFalse: [nil]
]

{ #category : #'as yet unclassified' }
SBBashFormattedTextBubble >> cursorPositionsDo: aBlock shallow: aBoolean [

	focusable ifTrue: [super cursorPositionsDo: aBlock shallow: aBoolean]
]

{ #category : #'as yet unclassified' }
SBBashFormattedTextBubble >> focusable [

	focusable ifNil: [^ true] ifNotNil: [^ focusable]
]

{ #category : #'as yet unclassified' }
SBBashFormattedTextBubble >> focusable: aBoolean [

	focusable := aBoolean
]

{ #category : #'as yet unclassified' }
SBBashFormattedTextBubble >> keyStroke: anEvent [

	^ true
]

{ #category : #'as yet unclassified' }
SBBashFormattedTextBubble >> wasSelected [

	focusable
		ifTrue: [super wasSelected]
		ifFalse: [(self parentSandblock isKindOf: SBBashCommandBlock) ifTrue: [self parentSandblock focus]]
]
