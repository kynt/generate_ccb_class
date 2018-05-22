require 'rexml/document'
require 'active_support'
require 'active_support/core_ext'

module BaseClass
  Layer = "CCLayer"
  Node = "CCNode"
  Sprite = "CCSprite"
  Label = "CCLabel"
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
  attr_reader :class_name, :attribute_map

  def initialize()
    @class_name = ""
    @attribute_map = {}
    for base_class_name in BaseClass.all
      @attribute_map[base_class_name] = Array.new
    end
  end

  def AnalyzeObject obj
    unless obj.has_key? "key"
      return
    end

    unless obj["key"][0] == "baseClass"
      return
    end

    target = obj["string"]
    AddTarget target
  end

  def AddTarget target
    attribute_name = ""
    # カスタムクラスがあるならそれ優先で変数割り当てになるはず
    custom_class = target[Index::CustomClass]
    unless custom_class == nil
      p target
      return
    end

    # カスタムクラスがないならベースクラスで割り当て
    base_class = target[Index::BaseClass]
    case base_class
    when BaseClass::Layer then
      # CCLayerはきっと1つでそのCCBが割り当てられるクラス名のはず
      @class_name = target[Index::CustomClass]
    when BaseClass::Node then
      attribute_name = BaseClass::Node
    when BaseClass::Sprite then
      attribute_name = BaseClass::Sprite
    when BaseClass::Label then
      attribute_name = BaseClass::Label
    when BaseClass::Button then
      attribute_name = BaseClass::Button
    when BaseClass::CCB then
      attribute_name = BaseClass::CCB
    else
    end

    if attribute_name.length != 0 && target[Index::AssignVariable] != nil
      @attribute_map[attribute_name] = target[Index::AssignVariable]
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
# XMLファイル読み込み
doc = REXML::Document.new(File.new("test.ccb"))

#Hashに変換
hash = Hash.from_xml(doc.to_s)

# 変数取得
ccb_parser = CcbParser.new
ccb_parser.SearchObject hash
