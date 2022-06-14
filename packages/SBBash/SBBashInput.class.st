Class {
	#name : #SBBashInput,
	#superclass : #SBBash,
	#instVars : [
		'terminal',
		'current',
		'processReturn'
	],
	#category : #SBBash
}

{ #category : #'as yet unclassified' }
SBBashInput class >> confirm: aBlock [
	<action>

	| pty terminal |
	terminal := aBlock containingArtefact.
	pty := terminal pty.
	terminal state: #hidden.
	Project current addDeferredUIMessage: [
		pty nextPutAll: (aBlock orOwnerSuchThat: [:b | b type = #command]) sourceString.
		pty nextPut: Character return]
]

{ #category : #'as yet unclassified' }
SBBashInput >> terminal [

	^ self containingArtefact
]
