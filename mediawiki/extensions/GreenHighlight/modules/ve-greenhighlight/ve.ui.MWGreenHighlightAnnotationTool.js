/*!
 * VisualEditor UserInterface MWGreenHighlightAnnotationTool class.
 */

/*global ve, OO */

/**
 * UserInterface green highlight tool.
 *
 * Registered in the 'textStyle' group, which is what both the desktop and the mobile
 * VisualEditor toolbars pull into their text styling menu, so the button shows up next
 * to bold, italic, strikethrough and the other character formatting tools.
 *
 * @class
 * @extends ve.ui.AnnotationTool
 * @constructor
 * @param {OO.ui.ToolGroup} toolGroup
 * @param {Object} [config] Configuration options
 */
ve.ui.MWGreenHighlightAnnotationTool = function VeUiMWGreenHighlightAnnotationTool() {
	// Parent constructor
	ve.ui.MWGreenHighlightAnnotationTool.super.apply( this, arguments );
};

OO.inheritClass( ve.ui.MWGreenHighlightAnnotationTool, ve.ui.AnnotationTool );

ve.ui.MWGreenHighlightAnnotationTool.static.name = 'mwGreenHighlight';

ve.ui.MWGreenHighlightAnnotationTool.static.group = 'textStyle';

ve.ui.MWGreenHighlightAnnotationTool.static.icon = 'greenHighlight';

ve.ui.MWGreenHighlightAnnotationTool.static.title = OO.ui.deferMsg(
	'greenhighlight-visualeditor-annotationbutton-tooltip'
);

ve.ui.MWGreenHighlightAnnotationTool.static.annotation = { name: 'textStyle/mwGreenHighlight' };

ve.ui.MWGreenHighlightAnnotationTool.static.commandName = 'mwGreenHighlight';

ve.ui.toolFactory.register( ve.ui.MWGreenHighlightAnnotationTool );

ve.ui.commandRegistry.register(
	new ve.ui.Command(
		'mwGreenHighlight', 'annotation', 'toggle',
		{
			args: [ 'textStyle/mwGreenHighlight' ],
			supportedSelections: [ 'linear', 'table' ]
		}
	)
);
