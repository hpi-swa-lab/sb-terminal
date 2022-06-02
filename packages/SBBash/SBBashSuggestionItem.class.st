Class {
	#name : #SBBashSuggestionItem,
	#superclass : #SBSuggestionItem,
	#instVars : [
		'option',
		'command'
	],
	#category : #SBBash
}

{ #category : #'as yet unclassified' }
SBBashSuggestionItem >> command [

	^ command
]

{ #category : #'as yet unclassified' }
SBBashSuggestionItem >> command: anObject [

	command := anObject
]

{ #category : #'as yet unclassified' }
SBBashSuggestionItem >> option [

	^ option
]

{ #category : #'as yet unclassified' }
SBBashSuggestionItem >> option: aString [

	option := aString
]
