/*!
 * VisualEditor ContentEditable MWGreenHighlightAnnotation class.
 */

/*global ve, OO */

/**
 * ContentEditable green highlight annotation.
 *
 * @class
 * @extends ve.ce.TextStyleAnnotation
 * @constructor
 * @param {ve.dm.MWGreenHighlightAnnotation} model Model to observe
 * @param {ve.ce.ContentBranchNode} [parentNode] Node rendering this annotation
 * @param {Object} [config] Configuration options
 */
ve.ce.MWGreenHighlightAnnotation = function VeCeMWGreenHighlightAnnotation() {
	// Parent constructor
	ve.ce.MWGreenHighlightAnnotation.super.apply( this, arguments );

	// DOM changes
	this.$element.addClass( 'mw-green-highlight' );
};

/* Inheritance */

OO.inheritClass( ve.ce.MWGreenHighlightAnnotation, ve.ce.TextStyleAnnotation );

/* Static Properties */

ve.ce.MWGreenHighlightAnnotation.static.name = 'textStyle/mwGreenHighlight';

ve.ce.MWGreenHighlightAnnotation.static.tagName = 'span';

/* Registration */

ve.ce.annotationFactory.register( ve.ce.MWGreenHighlightAnnotation );
