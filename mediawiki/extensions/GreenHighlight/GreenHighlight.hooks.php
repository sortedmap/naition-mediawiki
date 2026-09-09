<?php
/**
 * Hooks for the GreenHighlight extension.
 */
class GreenHighlightHooks {
	/**
	 * Load the highlight styles so that highlighted text is also green when reading,
	 * not only inside the visual editor.
	 *
	 * @param OutputPage $out
	 * @param Skin $skin
	 * @return bool
	 */
	public static function onBeforePageDisplay( OutputPage &$out, Skin &$skin ) {
		$out->addModuleStyles( 'ext.greenHighlight' );
		return true;
	}

	/**
	 * @param array &$testModules
	 * @param ResourceLoader &$resourceLoader
	 * @return bool
	 */
	public static function onResourceLoaderTestModules(
		array &$testModules,
		ResourceLoader &$resourceLoader
	) {
		$testModules['qunit']['ext.greenHighlight.test'] = array(
			'scripts' => array(
				'tests/ve.dm.MWGreenHighlightAnnotation.test.js',
			),
			'dependencies' => array(
				'ext.greenHighlight.visualEditor',
				'ext.visualEditor.test',
			),
			'localBasePath' => __DIR__,
			'remoteExtPath' => 'GreenHighlight',
		);
		return true;
	}
}
