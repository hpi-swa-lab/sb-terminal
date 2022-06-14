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
SBBashFormattedTextBubble >> focusable [

	^ focusable
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
