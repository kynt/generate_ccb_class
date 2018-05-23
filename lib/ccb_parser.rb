require 'rexml/document'
require 'active_support'
require 'active_support/core_ext'
require 'pp'

module BaseClass
  Layer = "CCLayer"
  Node = "CCNode"
  Sprite = "CCSprite"
  Label = "CCLabelTTF"
  Button = "CCControlButton"
  CCB = "CCBFile"

  def self.all
    self.constants.map{|name| self.const_get(name) }
  end
end

module Index
  BaseClass = 0
  CustomClass = 1
  Name = 2
  AssignVariable = 3

  def self.all
    self.constants.map{|name| self.const_get(name) }
  end
end

class CcbParser
  attr_reader :class_name, :custom_attribute_map, :attribute_map, :control_selector_list, :load_ccb_list

  def initialize
    @class_name = ""
    # ロードするCCB名
    @load_ccb_list = []

    # コントロールセレクター
    @control_selector_list = []

    # カスタムクラスで変数にアサインされるもの
    @custom_attribute_map = {}

    # ベースクラスで変数にアサインされるもの
    @attribute_map = {}
    for base_class_name in BaseClass.all
      concreate_class_name = GetConcreateClassName base_class_name
      @attribute_map[concreate_class_name] = Array.new
    end
  end

  def Load file_name
    doc = REXML::Document.new(File.new(file_name))
    hash = Hash.from_xml(doc.to_s)
    SearchObject hash
  end

  def AnalyzeObject obj
    unless obj.has_key? "key"
      return
    end

    unless obj["key"][0] == "baseClass"
      return
    end

    AnalyzeLoadCcb obj
    AnalyzeControlSelector obj
    AnalyzeAssignValue obj
  end

  def AnalyzeLoadCcb obj
    target = obj["string"]
    base_class = target[Index::BaseClass]
    name = target[Index::Name]

    case base_class
    when BaseClass::CCB then
      # カスタムクラスのくせにcustom_classに名前が入らないので苦肉の策で名前を代用する
      @load_ccb_list << name
    else
    end
  end

  def AnalyzeControlSelector obj
    target = obj["string"]
    if target[Index::BaseClass] == "CCControlButton"
      for var in obj["array"][1]["dict"]
        if var["string"][0] == "ccControl"
          @control_selector_list << var["array"]["string"]
        end
      end
    end
  end

  def AnalyzeAssignValue obj
    target = obj["string"]
    custom_class = target[Index::CustomClass]
    base_class = target[Index::BaseClass]
    name = target[Index::Name]
    assign_variable = target[Index::AssignVariable]

    # CCLayerはきっと1つでそのCCBが割り当てられるクラス名のはず
    if base_class == BaseClass::Layer
      @class_name = custom_class
      return
    end

    if assign_variable == nil
      return
    end

    # カスタムクラスがあるならそれ優先で変数割り当てになるはず
    if custom_class != nil
      if !@custom_attribute_map.has_key? custom_class
        @custom_attribute_map[custom_class] = []
      end
      @custom_attribute_map[custom_class] << assign_variable
      return
    end

    if base_class == nil
      return
    end

    case base_class
    when BaseClass::CCB then
      # カスタムクラスのくせにcustom_classに名前が入らないので苦肉の策で名前を代用する
      if !@custom_attribute_map.has_key? name
        @custom_attribute_map[name] = []
      end
      @custom_attribute_map[name] << assign_variable
    else
      concreate_class_name = GetConcreateClassName base_class
      @attribute_map[concreate_class_name] << assign_variable
    end
  end

  def GetConcreateClassName base_class_name
    case base_class_name
    when BaseClass::Layer then
      return "cocos2d::CCLayer"
    when BaseClass::Node then
      return "cocos2d::CCNode"
    when BaseClass::Sprite then
      return "cocos2d::CCSprite"
    when BaseClass::Label then
      return "cocos2d::CCLabelTTF"
    when BaseClass::Button then
       return "cocos2d::extension::CCControlButton"
     when BaseClass::CCB then
        return "CCB"
    else
      return ""
    end
  end

  def SearchObject obj
    case obj
    when Array
      obj.map{|e| SearchObject(e)} # Array の要素を再帰的に処理
    when Hash
      AnalyzeObject obj
      obj.inject({}) do |hash, (k, v)|
        hash[k] = SearchObject(v) # Hash の値を再帰的に処理
        hash
      end
    else
      obj
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  # 変数取得
  ccb_parser = CcbParser.new
  ccb_parser.Load "test.ccb"
  # p ccb_parser.class_name
  # pp ccb_parser.custom_attribute_map
  # pp ccb_parser.attribute_map
  # pp ccb_parser.control_selector_list
  pp ccb_parser.load_ccb_list
end
