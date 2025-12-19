"use client";

import { useEffect, useState } from "react";
import { Card } from "@/components/ui/card";
import { useAccount, useChainId } from "wagmi";
import { toast } from "sonner";
import { SMARTFLOW_ADDRESS } from "@/hooks/useSmartFlow";
import { shorten } from "../lib/utils";

export default function FooterCard() {
  const [mounted, setMounted] = useState(false);
  useEffect(
    () =>
      //eslint-disable-next-line
      setMounted(true),
    []
  );

  const { address } = useAccount();
  const chainId = useChainId();

  const network =
    chainId === 42161
      ? "Arbitrum One"
      : chainId === 1
      ? "Ethereum Mainnet"
      : "Unknown network";

  const copyToClipboard = (text: string) => {
    navigator.clipboard.writeText(text);
  };

  if (!mounted) {
    return (
      <Card className="rounded-2xl border border-white/10 bg-slate-900/60 p-6 text-sm text-muted-foreground">
        Loading…
      </Card>
    );
  }

  return (
    <Card className=" overflow-hidden p-6 gap-3">
      <div className="flex justify-between items-center">
        <span className="text-sm text-slate-300">Contract</span>

        <div className="flex items-center gap-2">
          <a
            href={`https://arbiscan.io/address/${SMARTFLOW_ADDRESS}`}
            target="_blank"
            rel="noopener noreferrer"
            className="text-cyan-400 hover:underline text-sm"
          >
            {shorten(SMARTFLOW_ADDRESS)}
          </a>

          <button
            onClick={() => {
              copyToClipboard(SMARTFLOW_ADDRESS);
              toast.success("Contract address copied");
            }}
            className="text-xs text-muted-foreground hover:text-foreground transition"
            title="Copy address"
          >
            📋
          </button>
        </div>
      </div>

      <div className="flex justify-between">
        <span className="text-sm text-slate-300">Network</span>
        <span className="text-sm text-white">{network}</span>
      </div>

      <div className="flex justify-between items-center">
        <span className="text-sm text-slate-300">Your address</span>

        {address ? (
          <div className="flex items-center gap-2">
            <a
              href={`https://arbiscan.io/address/${address}`}
              target="_blank"
              rel="noopener noreferrer"
              className="text-sm text-cyan-400 hover:underline"
            >
              {shorten(address)}
            </a>

            <button
              onClick={() => {
                copyToClipboard(address);
                toast.success("Wallet address copied");
              }}
              className="text-xs text-muted-foreground hover:text-foreground transition"
              title="Copy address"
            >
              📋
            </button>
          </div>
        ) : (
          <span>—</span>
        )}
      </div>
    </Card>
  );
}
