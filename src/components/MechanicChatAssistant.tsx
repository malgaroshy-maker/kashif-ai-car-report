"use client";

import React, { useState, useRef, useEffect } from "react";
import {
  MessageSquare,
  X,
  Send,
  Bot,
  User,
  Wrench,
  Loader2,
  HelpCircle,
} from "lucide-react";
import { KashifDiagnosticReport, ChatMessage } from "@/lib/types";

interface MechanicChatAssistantProps {
  report: KashifDiagnosticReport;
}

export const MechanicChatAssistant: React.FC<MechanicChatAssistantProps> = ({
  report,
}) => {
  const [isOpen, setIsOpen] = useState(false);
  const [inputMessage, setInputMessage] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [messages, setMessages] = useState<ChatMessage[]>([
    {
      id: "initial",
      sender: "assistant",
      text: `مرحبتين بيك! أنا المساعد الفني لتقرير (${report.vehicle.make} ${report.vehicle.model}). يمكنك الاستفسار عن تفاصيل الأعطال، أرقام القطع الأصلية، أو خطوات الصيانة المطلوبة.`,
      timestamp: new Date().toLocaleTimeString("ar-LY", {
        hour: "2-digit",
        minute: "2-digit",
      }),
    },
  ]);

  const messagesEndRef = useRef<HTMLDivElement>(null);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  };

  useEffect(() => {
    if (isOpen) {
      scrollToBottom();
    }
  }, [messages, isOpen]);

  const quickQuestions = [
    "ما هي التكلفة التقديرية للقطع؟",
    "هل الأعطال تؤثر على سلامة القيادة؟",
    "أين تتوفر قطع الغيار المعتمدة؟",
  ];

  const handleSendMessage = async (textToSend?: string) => {
    const text = (textToSend || inputMessage).trim();
    if (!text || isLoading) return;

    const userMsg: ChatMessage = {
      id: `user-${Date.now()}`,
      sender: "user",
      text,
      timestamp: new Date().toLocaleTimeString("ar-LY", {
        hour: "2-digit",
        minute: "2-digit",
      }),
    };

    setMessages((prev) => [...prev, userMsg]);
    setInputMessage("");
    setIsLoading(true);

    try {
      const storedApiKey = localStorage.getItem("kashif_gemini_api_key") || "";
      const activeProvider = localStorage.getItem("kashif_ai_provider") || "gemini";
      const storedModel = localStorage.getItem("kashif_gemini_model") || "";
      const headers: Record<string, string> = {
        "Content-Type": "application/json",
        "x-ai-provider": activeProvider,
      };
      if (storedApiKey) {
        headers["x-gemini-api-key"] = storedApiKey;
      }
      if (storedModel) {
        headers["x-gemini-model"] = storedModel;
      }

      const res = await fetch("/api/chat", {
        method: "POST",
        headers,
        body: JSON.stringify({
          report,
          question: text,
          history: messages,
          apiKey: storedApiKey || undefined,
          model: storedModel || undefined,
          provider: activeProvider,
        }),
      });

      const data = await res.json();
      const replyText = data.reply || data.answer;
      if (replyText) {
        const assistantMsg: ChatMessage = {
          id: `asst-${Date.now()}`,
          sender: "assistant",
          text: replyText,
          timestamp: new Date().toLocaleTimeString("ar-LY", {
            hour: "2-digit",
            minute: "2-digit",
          }),
        };
        setMessages((prev) => [...prev, assistantMsg]);
      } else {
        throw new Error(data.error || "تعذر الحصول على الرد");
      }
    } catch (err: any) {
      const errorMsg: ChatMessage = {
        id: `err-${Date.now()}`,
        sender: "assistant",
        text: "تعذر الاتصال حالياً، يرجى إعادة المحاولة.",
        timestamp: new Date().toLocaleTimeString("ar-LY", {
          hour: "2-digit",
          minute: "2-digit",
        }),
      };
      setMessages((prev) => [...prev, errorMsg]);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <>
      {/* Floating Chat Button */}
      <button
        onClick={() => setIsOpen(true)}
        className="fixed bottom-5 left-5 z-50 bg-blue-600 hover:bg-blue-500 text-white font-bold p-3.5 rounded-xl shadow-xl flex items-center gap-2 transition-colors cursor-pointer no-print"
      >
        <MessageSquare className="w-4 h-4" />
        <span className="hidden sm:inline font-heading text-xs">
          استفسار فني (AI)
        </span>
      </button>

      {/* Chat Drawer */}
      {isOpen && (
        <div className="fixed bottom-5 left-5 z-50 w-full max-w-sm bg-[#0F172A] border border-slate-700 rounded-2xl shadow-2xl overflow-hidden flex flex-col h-[500px] max-h-[80vh] no-print">
          {/* Header */}
          <div className="p-3.5 bg-slate-900 border-b border-slate-800 flex items-center justify-between">
            <div className="flex items-center gap-2.5">
              <div className="w-8 h-8 rounded-lg bg-blue-600 flex items-center justify-center text-white">
                <Bot className="w-4 h-4" />
              </div>
              <div>
                <h4 className="text-xs font-bold text-white font-heading">
                  المساعد الفني الذكي
                </h4>
                <p className="text-[10px] text-slate-400 font-mono">
                  {report.vehicle.make} {report.vehicle.model}
                </p>
              </div>
            </div>

            <button
              onClick={() => setIsOpen(false)}
              className="text-slate-400 hover:text-white p-1 rounded hover:bg-slate-800 cursor-pointer"
            >
              <X className="w-4 h-4" />
            </button>
          </div>

          {/* Messages Body */}
          <div className="flex-1 overflow-y-auto p-3.5 space-y-3 bg-[#090D16]">
            {messages.map((msg) => (
              <div
                key={msg.id}
                className={`flex gap-2 ${
                  msg.sender === "user" ? "flex-row-reverse" : "flex-row"
                }`}
              >
                <div
                  className={`w-6 h-6 rounded flex items-center justify-center shrink-0 text-xs ${
                    msg.sender === "user"
                      ? "bg-blue-600 text-white"
                      : "bg-slate-800 text-blue-400 border border-slate-700"
                  }`}
                >
                  {msg.sender === "user" ? (
                    <User className="w-3.5 h-3.5" />
                  ) : (
                    <Wrench className="w-3.5 h-3.5" />
                  )}
                </div>

                <div
                  className={`max-w-[85%] rounded-xl p-2.5 text-xs leading-relaxed ${
                    msg.sender === "user"
                      ? "bg-blue-600 text-white rounded-tr-none"
                      : "bg-[#0F172A] text-slate-200 border border-slate-800 rounded-tl-none whitespace-pre-line"
                  }`}
                >
                  <p>{msg.text}</p>
                  <span className="text-[9px] text-slate-400 block mt-1 text-left font-mono">
                    {msg.timestamp}
                  </span>
                </div>
              </div>
            ))}

            {isLoading && (
              <div className="flex gap-2 items-center text-xs text-slate-400 bg-slate-900 p-2.5 rounded-xl border border-slate-800 w-fit">
                <Loader2 className="w-3.5 h-3.5 animate-spin text-blue-400" />
                <span>جاري إعداد الرد الفني...</span>
              </div>
            )}
            <div ref={messagesEndRef} />
          </div>

          {/* Quick Suggestions */}
          <div className="p-2 bg-slate-900 border-t border-slate-800 flex items-center gap-1.5 overflow-x-auto">
            <span className="text-[10px] text-slate-400 font-semibold flex items-center gap-1 shrink-0">
              <HelpCircle className="w-3 h-3 text-blue-400" />
              مقترحات:
            </span>
            {quickQuestions.map((q, idx) => (
              <button
                key={idx}
                onClick={() => handleSendMessage(q)}
                disabled={isLoading}
                className="text-[10px] bg-slate-800 hover:bg-slate-700 text-slate-300 px-2 py-0.5 rounded border border-slate-700 whitespace-nowrap cursor-pointer disabled:opacity-50"
              >
                {q}
              </button>
            ))}
          </div>

          {/* Input Footer */}
          <form
            onSubmit={(e) => {
              e.preventDefault();
              handleSendMessage();
            }}
            className="p-2.5 bg-slate-900 border-t border-slate-800 flex items-center gap-2"
          >
            <input
              type="text"
              placeholder="اكتب استفسارك هنا..."
              value={inputMessage}
              onChange={(e) => setInputMessage(e.target.value)}
              className="flex-1 bg-[#090D16] border border-slate-700 rounded-lg px-3 py-1.5 text-xs text-white placeholder-slate-500 focus:outline-none focus:border-blue-500"
            />
            <button
              type="submit"
              disabled={!inputMessage.trim() || isLoading}
              className="bg-blue-600 hover:bg-blue-500 text-white p-2 rounded-lg transition-colors disabled:opacity-50 cursor-pointer shrink-0"
            >
              <Send className="w-3.5 h-3.5 rotate-180" />
            </button>
          </form>
        </div>
      )}
    </>
  );
};
