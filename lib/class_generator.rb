# coding: utf-8
require 'json'

# クラス自動生成実行用クラス
class ClassGenerator
  attr_reader :class_name

  def initialize(class_name, file_name)
    @class_name = class_name
    @file_name = file_name
  end

  # 詳細の文字列を取得する
  # json :: descriptionを含むjsonのハッシュ
  def get_description(json)
    description = json["description"]
    return description.nil? ? "No document" : description
  end

  def get_header_class_code()
    return """#pragma once
#include \"CCHttpNetwork.h\"

JOKER_BEGIN_NAMESPACE
class #{@class_name} : public Chaos::network::CCHttpNetworkDelegate
{
public:
    #{@class_name}();
    virtual ~#{@class_name}();

    Bool Request(std::function<void(bool)> callback);

private:
    virtual void onHttpRequestOnErrorByADK(int errorCode, TErrorDetail& msg);
    virtual bool onHttpNetworkError(int errorCode);
    virtual void onHttpRequestResponseByADK(const adk::LIB_JsonDocument& json);

    std::function<void(bool)> callback_;
};
JOKER_END_NAMESPACE
"""
  end

  def get_implement_class_code()
    return """#include \"#{@file_name}.h\"
#include <core/library/lib_json_document.h>
#include \"network/api_lib.h\"
#include \"NEED_FOR_REFACTOR/Util.h\"

/// include parameter class and parse response
#include \"parameter/parameter_manager.h\"
/// #include \"parameter/guild_battle_season_parameter.h\"

JOKER_BEGIN_NAMESPACE

#{@class_name}::#{@class_name}() : callback_(nullptr) {}
#{@class_name}::~#{@class_name}() {
    callback_ = nullptr;
}

static Char* MakeRequest(char* buffer, size_t buffer_len, size_t& request_size) {
    adk::LIB_JsonDocument doc;
    doc.BeginObject();

    /* デフォルトパラメーター設定 */
    JOKER::TRequestBuffer requestIdTmp;
    U32 n = network::MakeDefaultParam(doc, requestIdTmp);
    doc.EndObject(n);
    doc.Assign();

    Char* ret = network::MakeRequestData(doc, buffer, buffer_len, &request_size);
    doc.Release();
    return ret;
}

void #{@class_name}::onHttpRequestResponseByADK(const adk::LIB_JsonDocument &json) {
    LOADER_SCENE_REMOVE;
    S32 ret = false;
    const adk::LIB_JsonValue& status = json[\"status\"].data;
    ret = status.IsNumber();
    if (ret==true && status.GetS32()!=200) {
        ret = false;
    } else {
        ParameterManager* parameter_manager = JokerApplication::GetInstance()->GetParameterManager();

        ((adk::LIB_JsonDocument&)json).Release();

        if (callback_) {
            callback_(true);
        }
        callback_ = nullptr;
    }
}

bool #{@class_name}::onHttpNetworkError(int errorCode) {
    LOADER_SCENE_REMOVE;
    if (callback_) {
        callback_(false);
    }
    callback_ = nullptr;
    return true;
}

void #{@class_name}::onHttpRequestOnErrorByADK(int errorCode, TErrorDetail& msg) {
    LOADER_SCENE_REMOVE;
    if (callback_) {
        callback_(false);
    }

    callback_ = nullptr;
    CCHttpNetworkDelegate::onHttpRequestOnErrorByADK(errorCode, msg);
}

Bool #{@class_name}::Request(std::function<void(bool)> callback) {
    callback_ = callback;
    char request_buffer[8192];
    memset(request_buffer, 0, sizeof(request_buffer));
    size_t request_size;

    Char* request = MakeRequest(request_buffer, sizeof(request_buffer), request_size);
    JOKER_ASSERT(request);
    if (request == 0) {
        return false;
    }

    LOADER_SCENE_ADDCHILD;
    //    network::RequestApi(\"/api/usercarddeck/guild/update/\", request, request_size, this);
    if (request != request_buffer) {
        free(request);
    }

    return true;
}

JOKER_END_NAMESPACE
"""
  end
end
