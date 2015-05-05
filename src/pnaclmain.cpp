// Copyright (c) 2013 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// These are libraies needed for basic types and such
#include "ppapi/cpp/instance.h"
#include "ppapi/cpp/module.h"
#include "ppapi/cpp/var.h"
#include "ppapi/cpp/var_dictionary.h"
#include "ppapi/cpp/var_array.h"
#include "ppapi/cpp/var_array_buffer.h"
#include <string>
#include <vector>

class PNaclInstance : public pp::Instance {
    public:
        explicit PNaclInstance(PP_Instance instance)
            : pp::Instance(instance) {
        }
        virtual ~PNaclInstance() {}

    public:
        virtual void HandleMessage(const pp::Var& var_message) {
            // Ignore the message if it is not an object
            if (!var_message.is_dictionary()) { return; }

            pp::VarDictionary msg(var_message);

            pp::Var vFn = msg.Get("fn");

            // Ignore the message if it doesn't have a string fn specified
            if (!vFn.is_string()) { return; }
            std::string fn(vFn.AsString());

            pp::VarDictionary response;
            if (fn == "init") {
                response = handleMsgInit(msg);
            } else if (fn == "readImage") {
                response = handleMsgForImage("gcip", msg);
            } else if (fn == "getRects") {
                response = handleMsgForImage("rect", msg);
            } else if (fn == "setChallengeResponse") {
                challenge_response = msg.Get("response").AsString();
                return;
            }
            PostMessage(response);
        }

        pp::VarDictionary handleMsgInit(pp::VarDictionary& msg) {
            pp::VarDictionary response;
            response.Set("message", "version");
            response.Set("version", "1.2.3.4");
            response.Set("challenge", "Why do you care??");
            return response;
        }

        pp::VarDictionary makePointDict(int x, int y) {
            pp::VarDictionary outPoint;
            outPoint.Set("x", x);
            outPoint.Set("y", y);
            return outPoint;
        }

        pp::VarArray makeRectsArray() {
            pp::VarArray outArray;
            int count = 15;
            outArray.SetLength(count);
            for (int i = 0; i < count; ++i) {
                pp::VarDictionary dict;
                dict.Set("tl", 5 * i, 5 * i);
                dict.Set("tr", 10 * i, 5 * i);
                dict.Set("bl", 5 * i, 10 * i);
                dict.Set("br", 10 * i, 10 * i);
                outArray.Set(i, dict);
            }
            return outArray;
        }

        pp::VarDictionary handleMsgForImage(const std::string& fn, pp::VarDictionary& msg) {
            pp::VarDictionary response;
            response.Set("message", fn);
            pp::Var vWidth = msg.Get("width"),
                    vHeight = msg.Get("height"),
                    vBuf = msg.Get("buf");
            if (!vWidth.is_number()) {
                response.Set("error", "expected width to be number!");
                return response;
            }
            if (!vHeight.is_number()) {
                response.Set("error", "expected height to be number!");
                return response;
            }
            if (!vBuf.is_array_buffer()) {
                response.Set("error", "expected buffer!");
                return response;
            }
            int32_t width(vWidth.AsInt()),
                    height(vHeight.AsInt());
            pp::VarArrayBuffer buf(vBuf);
            if (buf.ByteLength() != width*height) {
                std::string errorMsg = "invalid buffer length.";
                errorMsg += " Expected: " + boost::lexical_cast<std::string>(width*height);
                errorMsg += " but got: " +  boost::lexical_cast<std::string>(buf.ByteLength());
                response.Set("error", errorMsg);
                return response;
            }

            // Now that all the conversion and error correction is done...
            unsigned char* img = static_cast<unsigned char*>(buf.Map());

            RectVector rects;
            if (fn == "gcip") {
                rects = gcip->readImage(width, height, img);
                if (checkAuth()) {
                    response.Set("scan", gcip->getLastScan());
                } else {
                    response.Set("scan", "bad auth");
                }
            } else {
                rects = gcip->hasRect(width, height, img);
            }
            response.Set("rects", makeRectsArray(rects));
            return response;
        }
};

class PNaclModule : public pp::Module {
    public:
        PNaclModule() : pp::Module() {}
        virtual ~PNaclModule() {}

        virtual pp::Instance* CreateInstance(PP_Instance instance) {
            return new PNaclInstance(instance);
        }
};

namespace pp {

    Module* CreateModule() {
        return new PNaclModule();
    }

}  // namespace pp
