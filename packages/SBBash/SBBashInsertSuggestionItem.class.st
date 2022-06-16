Class {
	#name : #SBBashInsertSuggestionItem,
	#superclass : #SBInsertSuggestionItem,
	#instVars : [
		'option',
		'command'
	],
	#category : #SBBash
}

{ #category : #'as yet unclassified' }
SBBashInsertSuggestionItem >> command [

	^ command
]

{ #category : #'as yet unclassified' }
SBBashInsertSuggestionItem >> command: anObject [

	command := anObject
]

{ #category : #'as yet unclassified' }
SBBashInsertSuggestionItem >> option [

	^ option
]

{ #category : #'as yet unclassified' }
SBBashInsertSuggestionItem >> option: anObject [

	option := anObject
]
