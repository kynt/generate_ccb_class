# coding: utf-8
require 'json'
require_relative './ccb_parser'

# クラス自動生成実行用クラス
class ClassGenerator
  attr_reader :file_name

  def initialize(file_name)
    @file_name = File.basename(file_name, ".ccb")
    @ccb_parser = CcbParser.new
    @ccb_parser.Load file_name
    @class_name = @ccb_parser.class_name
  end

  def get_release_variable
    attribute_map = @ccb_parser.attribute_map
    attribute_map.sort
    variable_str = ""
    attribute_map.each_pair {|key, value_list|
      value_list.each do |val|
        if variable_str.length == 0
          variable_str = "    CC_SAFE_RELEASE(" + val + ")"
        else
          variable_str = variable_str + "\n"
          variable_str = variable_str + "    CC_SAFE_RELEASE(" + val + ")"
        end
      end
    }

    custom_attribute_map = @ccb_parser.custom_attribute_map
    custom_attribute_map.sort
    custom_attribute_map.each_pair {|key, value_list|
      value_list.each do |val|
        if variable_str.length == 0
          variable_str = "    CC_SAFE_RELEASE(" + val + ")"
        else
          variable_str = variable_str + "\n"
          variable_str = variable_str + "    CC_SAFE_RELEASE(" + val + ")"
        end
      end
    }

    return variable_str
  end

  def get_assign_variable
    attribute_map = @ccb_parser.attribute_map
    attribute_map.sort
    variable_str = ""
    attribute_map.each_pair {|key, value_list|
      value_list.each do |val|
        if variable_str.length == 0
          variable_str = "        " + key
        else
          variable_str = variable_str + "\n"
          variable_str = variable_str + "        " + key
        end
        variable_str = variable_str + "* " + val + " = nullptr;"
      end
    }

    custom_attribute_map = @ccb_parser.custom_attribute_map
    custom_attribute_map.sort
    custom_attribute_map.each_pair {|key, value_list|
      value_list.each do |val|
        if variable_str.length == 0
          variable_str = "        " + key
        else
          variable_str = variable_str + "\n"
          variable_str = variable_str + "        " + key
        end
        variable_str = variable_str + "* " + val + " = nullptr;"
      end
    }

    return variable_str
  end

  def get_button_listner_code is_header
    control_selector_list = @ccb_parser.control_selector_list

    listener_str = ""
    for selector_name_org in control_selector_list
      selector_name = selector_name_org.delete ":"
      tmp_str = "virtual void " + selector_name + "(cocos2d::CCObject *object, cocos2d::extension::CCControlEvent event)";
      if is_header
        tmp_str = tmp_str + ";"
      else
        tmp_str = tmp_str + "{\n\n}\n"
      end

      if listener_str.length == 0
        listener_str = "        " + tmp_str
      else
        listener_str = listener_str + "\n" + "        " + tmp_str
      end
    end

    return listener_str
  end

  def get_button_listner_implement_code
    control_selector_list = @ccb_parser.control_selector_list

    listener_str = ""
    for selector_name_org in control_selector_list
      selector_name = selector_name_org.delete ":"
      tmp_str = "void #{@class_name}::" + selector_name + "(cocos2d::CCObject *object, cocos2d::extension::CCControlEvent event)";
      tmp_str = tmp_str + "{\n\n}\n"

      if listener_str.length == 0
        listener_str = "" + tmp_str
      else
        listener_str = listener_str + "\n" + tmp_str
      end
    end

    return listener_str
  end

  def get_load_ccb_code
    load_code = "    CCNodeLoaderLibrary* node_loader = pCCBReader->getNodeLoaderLibrary();"
    for load_ccb_class in @ccb_parser.load_ccb_list
      load_code = load_code + "\n"
      load_code = load_code + "    node_loader->registerCCNodeLoader(\"#{load_ccb_class}\", #{load_ccb_class}BuilderLoader::loader());"
    end

    return load_code
  end

  def get_member_assign_code
    member_assign_code = ""
    attribute_map = @ccb_parser.attribute_map
    attribute_map.sort
    attribute_map.each_pair {|key, value_list|
      value_list.each do |val|
        if member_assign_code.length != 0
          member_assign_code = member_assign_code + "\n"
        end

        member_assign_code = member_assign_code + "    CCB_MEMBERVARIABLEASSIGNER_GLUE(this, \"" + val + "\", " + key + "*, " + val + ");"
      end
    }

    custom_attribute_map = @ccb_parser.custom_attribute_map
    custom_attribute_map.sort
    custom_attribute_map.each_pair {|key, value_list|
      value_list.each do |val|
        if member_assign_code.length != 0
          member_assign_code = member_assign_code + "\n"
        end

        member_assign_code = member_assign_code + "    CCB_MEMBERVARIABLEASSIGNER_GLUE(this, \"" + val + "\", " + key + "*, " + val + ");"
      end
    }

    return member_assign_code
  end

  def get_ccconrol_glue_code
    glue_code = ""
    control_selector_list = @ccb_parser.control_selector_list
    for selector in control_selector_list
      if glue_code.length != 0
        glue_code = glue_code + "\n"
      end
      method_name = selector.delete ":"
      glue_code = glue_code + "    CCB_SELECTORRESOLVER_CCCONTROL_GLUE(this, \"#{selector}\", #{@class_name}::#{method_name});"
    end

    return glue_code
  end

  # 詳細の文字列を取得する
  # json :: descriptionを含むjsonのハッシュ
  def get_description(json)
    description = json["description"]
    return description.nil? ? "No document" : description
  end

  def get_header_class_code()
    listener_str = get_button_listner_code true
    variable_str = get_assign_variable
    return """#pragma once
    #include <cocos-ext.h>
    #include <cocos2d.h>

    JOKER_BEGIN_NAMESPACE

    class #{@class_name}
    : public cocos2d::CCLayer
    , public cocos2d::extension::CCBSelectorResolver
    , public cocos2d::extension::CCBMemberVariableAssigner
    {
    public:
        ~#{@class_name}();
        virtual void onEnter() override;

    private:
        /**
         * \brief CCBのアサイン系処理
         */
        virtual void onLoadCCB(cocos2d::CCNode* pParent, cocos2d::extension::CCBReader* pCCBReader);
        virtual cocos2d::SEL_MenuHandler onResolveCCBCCMenuItemSelector(CCObject* pTarget, const char* pSelectorName) override;
        virtual cocos2d::extension::SEL_CCControlHandler onResolveCCBCCControlSelector(cocos2d::CCObject* pTarget, const char* pSelectorName) override;
        virtual cocos2d::SEL_CallFuncN onResolveCCBCCCallFuncSelector(CCObject * pTarget, const char* pSelectorName) override;
        virtual bool onAssignCCBMemberVariable(CCObject* pTarget, const char* pMemberVariableName, CCNode* pNode) override;

        /**
         * \brief ビュー初期化処理
         */
        virtual void InitializeView();

       /**
        * \brief ボタン押下処理
        */
#{listener_str}

        /// 変数
#{variable_str}
    };

    JOKER_END_NAMESPACE
"""
  end

  def get_implement_class_code()
    release_code = get_release_variable
    load_code = get_load_ccb_code
    assign_code = get_member_assign_code
    glue_code = get_ccconrol_glue_code
    button_listner_code = get_button_listner_implement_code
    return """#include \"#{@file_name}.h\"
#include \"application/joker_application.h\"
#include \"ccb/parts/button/CCBPartsButtonSoundTap.h\"
#include \"NEED_FOR_REFACTOR/Util.h\"

JOKER_BEGIN_NAMESPACE

#{@class_name}::~#{@class_name}() {
#{release_code}
}

void #{@class_name}::onEnter() {
    CCLayer::onEnter();
    InitializeView();
}

void #{@class_name}::onLoadCCB(CCNode* pParent, CCBReader* pCCBReader) {
#{load_code}
}

SEL_MenuHandler #{@class_name}::onResolveCCBCCMenuItemSelector(CCObject* pTarget, const char* pSelectorName) {
    return nullptr;
}

SEL_CCControlHandler #{@class_name}::onResolveCCBCCControlSelector(CCObject* pTarget, const char* pSelectorName) {
#{glue_code}
    return nullptr;
}

cocos2d::SEL_CallFuncN #{@class_name}::onResolveCCBCCCallFuncSelector(CCObject * pTarget, const char* pSelectorName) {
    return nullptr;
}

bool #{@class_name}::onAssignCCBMemberVariable(CCObject* pTarget, const char* pMemberVariableName, CCNode* pNode) {
#{assign_code}
    return false;
}

void #{@class_name}::InitializeView() {

}

#{button_listner_code}
JOKER_END_NAMESPACE
"""
  end
end

if __FILE__ == $PROGRAM_NAME
  # 変数取得
  generator = ClassGenerator.new "test.ccb"
  # p generator.get_header_class_code
  generator.get_implement_class_code
end
