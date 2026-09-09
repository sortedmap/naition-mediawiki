/*!
 * VisualEditor DataModel MWGreenHighlightAnnotation tests.
 */

/*global ve, QUnit */

QUnit.module( 've.dm.MWGreenHighlightAnnotation' );

QUnit.test( 'the tool is in the text style menu', function ( assert ) {
	var tool = ve.ui.toolFactory.lookup( 'mwGreenHighlight' );

	QUnit.expect( 4 );

	assert.ok( tool, 'the tool is registered' );
	assert.strictEqual( tool.static.group, 'textStyle',
		'the tool is in the textStyle group, which the styling menu includes' );
	assert.deepEqual( ve.ui.MoreTextStyleTool.static.groupConfig.include[ 0 ],
		{ group: 'textStyle' }, 'the styling menu includes the whole textStyle group' );
	assert.strictEqual(
		ve.ui.MoreTextStyleTool.static.groupConfig.demote.indexOf( 'mwGreenHighlight' ), -1,
		'the tool is not demoted below the rarely used tools' );
} );

QUnit.test( 'the command toggles the annotation', function ( assert ) {
	var command = ve.ui.commandRegistry.lookup( 'mwGreenHighlight' );

	QUnit.expect( 4 );

	assert.ok( command, 'the command is registered' );
	assert.strictEqual( command.getAction(), 'annotation' );
	assert.strictEqual( command.getMethod(), 'toggle' );
	assert.deepEqual( command.getArgs(), [ 'textStyle/mwGreenHighlight' ] );
} );

QUnit.test( 'matchElement', function ( assert ) {
	var i,
		cases = [
			{
				msg: 'a span with the highlight class matches',
				html: '<span class="mw-green-highlight"></span>',
				expected: 'textStyle/mwGreenHighlight'
			},
			{
				msg: 'the class may sit next to other classes',
				html: '<span class="foo mw-green-highlight bar"></span>',
				expected: 'textStyle/mwGreenHighlight'
			},
			{
				msg: 'a plain span is left to the generic span annotation',
				html: '<span></span>',
				expected: 'textStyle/span'
			},
			{
				msg: 'a similarly named class does not match',
				html: '<span class="mw-green-highlighter"></span>',
				expected: 'textStyle/span'
			}
		];

	QUnit.expect( cases.length );

	for ( i = 0; i < cases.length; i++ ) {
		assert.strictEqual(
			ve.dm.modelRegistry.matchElement( $( cases[ i ].html )[ 0 ] ),
			cases[ i ].expected,
			cases[ i ].msg
		);
	}
} );

QUnit.test( 'toDomElements', function ( assert ) {
	var annotation = ve.dm.annotationFactory.create( 'textStyle/mwGreenHighlight' ),
		domElements = annotation.constructor.static.toDomElements(
			annotation.getElement(), document
		);

	QUnit.expect( 1 );

	assert.strictEqual( domElements[ 0 ].outerHTML,
		'<span class="mw-green-highlight"></span>',
		'the annotation serialises to a span carrying the class' );
} );

QUnit.test( 'converter round trip', function ( assert ) {
	var offset, i,
		html = '<p>a <span class="mw-green-highlight">b</span> c</p>',
		model = ve.dm.converter.getModelFromDom(
			ve.createDocumentFromHtml( html ), null, new ve.dm.IndexValueStore()
		),
		data = model.data.getData();

	QUnit.expect( 2 );

	for ( i = 0; i < data.length; i++ ) {
		if ( Array.isArray( data[ i ] ) && data[ i ][ 0 ] === 'b' ) {
			offset = i;
			break;
		}
	}

	assert.deepEqual(
		model.data.getAnnotationsFromOffset( offset ).get().map( function ( annotation ) {
			return annotation.name;
		} ),
		[ 'textStyle/mwGreenHighlight' ],
		'the highlighted character carries the annotation'
	);
	assert.strictEqual(
		ve.dm.converter.getDomFromModel( model ).body.innerHTML, html,
		'the markup survives a round trip'
	);
} );

QUnit.test( 'the annotation renders as a span with the class', function ( assert ) {
	var annotation = ve.dm.annotationFactory.create( 'textStyle/mwGreenHighlight' ),
		view = ve.ce.annotationFactory.create( 'textStyle/mwGreenHighlight', annotation );

	QUnit.expect( 2 );

	assert.strictEqual( view.$element.prop( 'tagName' ).toLowerCase(), 'span' );
	assert.ok( view.$element.hasClass( 'mw-green-highlight' ) );
} );
