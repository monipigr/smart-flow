"use client";
import { Card } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { RotateCw } from "lucide-react";
import { useGetPrice, useGetThreshold } from "@/hooks/useSmartFlow";

export default function PriceCard() {
  const { data: price, isLoading, isFetching, refetch } = useGetPrice();
  const { data: threshold } = useGetThreshold();

  return (
    <Card className="relative overflow-hidden p-6 gap-3">
      <div className="space-y-4">
        <div className="flex items-center justify-between">
          <h2 className="text-sm font-medium tracking-wide text-white">
            ETH / USD Price
          </h2>

          <Badge className="bg-emerald-500/20 text-emerald-400 border border-emerald-500/30">
            ● Live
          </Badge>
        </div>
      </div>

      <div className="flex">
        {isLoading ? (
          <p className="text-slate-400">Loading price…</p>
        ) : (
          <p className="text-4xl font-bold tracking-tight text-cyan-400">
            ${(Number(price) / 1e8).toFixed(2)}
          </p>
        )}
        <Button
          variant="ghost"
          size="icon"
          onClick={() => refetch()}
          disabled={isFetching}
          className="rounded-full text-slate-200"
        >
          <RotateCw
            className={`h-4 w-4 transition ${isFetching ? "animate-spin" : ""}`}
          />
        </Button>
      </div>

      <p className="text-sm text-slate-400">
        Threshold:{" "}
        <span className="font-medium text-white">
          ${(Number(threshold) / 1e8).toLocaleString()}
        </span>
      </p>
    </Card>
  );
}
