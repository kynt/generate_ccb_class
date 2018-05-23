module Constant
  CustomClassAssignerMap = {
    'CCBScenePartsFooter' => {
      'include' => "#include \"ccb/parts/CCBScenePartsFooter.h\"",
      'namespace' => 'Chaos::CCB::Parts::',
      'loader' => 'CCBScenePartsFooterBuilderLoader'
    },
    'CCBPartsButtonSoundTap' => {
      'include' => "#include \"ccb/parts/button/CCBPartsButtonSoundTap.h\"",
      'namespace' => 'Chaos::CCB::Parts::Button::',
      'loader' => 'CCBPartsButtonSoundTapBuilderLoader'
    },
    'ScrollableSoundButton' => {
      'include' => "#include \"custom_view/scrollable_button.h\"",
      'namespace' => 'JOKER::',
      'loader' => 'ScrollableSoundButtonLoader'
    },
    'CCBScenePartsBeltHeader' => {
      'include' => "#include \"ccb/parts/ccb_scene_parts_belt_header.h\"",
      'namespace' => 'JOKER::',
      'loader' => 'CCBScenePartsBeltHeaderLoader'
    }
  }
end
