/*!
 * VisualEditor DataModel MWGreenHighlightAnnotation class.
 */

/*global ve, OO */

/**
 * DataModel green highlight annotation.
 *
 * Represents `<span class="mw-green-highlight">` tags. A class is used rather than an
 * inline style so that the colour stays configurable from the stylesheet, and `<span>`
 * with a class survives both the MediaWiki and the Parsoid sanitizers.
 *
 * @class
 * @extends ve.dm.TextStyleAnnotation
 * @constructor
 * @param {Object} element
 */
ve.dm.MWGreenHighlightAnnotation = function VeDmMWGreenHighlightAnnotation() {
	// Parent constructor
	ve.dm.MWGreenHighlightAnnotation.super.apply( this, arguments );
};

/* Inheritance */

OO.inheritClass( ve.dm.MWGreenHighlightAnnotation, ve.dm.TextStyleAnnotation );

/* Static Properties */

ve.dm.MWGreenHighlightAnnotation.static.name = 'textStyle/mwGreenHighlight';

ve.dm.MWGreenHighlightAnnotation.static.className = 'mw-green-highlight';

ve.dm.MWGreenHighlightAnnotation.static.matchTagNames = [ 'span' ];

ve.dm.MWGreenHighlightAnnotation.static.matchFunction = function ( domElement ) {
	return ( domElement.getAttribute( 'class' ) || '' ).split( /\s+/ )
		.indexOf( this.className ) !== -1;
};

ve.dm.MWGreenHighlightAnnotation.static.toDataElement = function () {
	return { type: this.name };
};

ve.dm.MWGreenHighlightAnnotation.static.toDomElements = function ( dataElement, doc ) {
	var domElement = doc.createElement( 'span' );
	domElement.setAttribute( 'class', this.className );
	return [ domElement ];
};

/* Registration */

ve.dm.modelRegistry.register( ve.dm.MWGreenHighlightAnnotation );
