"use client";

import { useEffect, useState } from "react";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { useAccount, useWaitForTransactionReceipt } from "wagmi";
import { toast } from "sonner";
import { formatDate, formatRemaining } from "../lib/utils";
import {
  useClaimMyReward,
  useLastClaimAt,
  useCooldown,
  useGetPrice,
  useGetThreshold,
} from "@/hooks/useSmartFlow";

export default function ClaimCard() {
  const { address, isConnected } = useAccount();
  const { data: lastClaimAt, refetch: refetchLastClaimAt } =
    useLastClaimAt(address);
  const { data: cooldown } = useCooldown();
  const { claim, isPending, error, hash } = useClaimMyReward();
  const { isSuccess, isError } = useWaitForTransactionReceipt({ hash });
  const [now, setNow] = useState<bigint | null>(null);
  const ARBISCAN_TX = (hash?: `0x${string}`) =>
    `https://arbiscan.io/tx/${hash}`;
  const { data: price } = useGetPrice();
  const { data: threshold } = useGetThreshold();

  const isPriceReady = Number(price) <= Number(threshold) ? true : false;

  useEffect(() => {
    const id = setInterval(() => {
      setNow(BigInt(Math.floor(Date.now() / 1000)));
    }, 1000);
    return () => clearInterval(id);
  }, []);

  useEffect(() => {
    if (isError || error) {
      toast.error("Claim failed", {
        description: error?.message ?? "Transaction reverted",
      });
    }
  }, [isError, error]);

  useEffect(() => {
    if (isSuccess && hash) {
      refetchLastClaimAt();
      toast.success("Reward claimed!", {
        description: (
          <a
            href={ARBISCAN_TX(hash)}
            target="_blank"
            rel="noopener noreferrer"
            className="underline text-cyan-400"
          >
            View transaction on Arbiscan ↗
          </a>
        ),
      });
    }
  }, [isSuccess, hash, refetchLastClaimAt]);

  if (now === null) {
    return (
      <Card className="p-6 gap-6">
        <Button disabled className="w-full text-white">
          Loading…
        </Button>
      </Card>
    );
  }

  const last = lastClaimAt ?? 0n;
  const cd = cooldown ?? 0n;

  const nextClaimAt = last + cd;
  const remaining = nextClaimAt > now ? nextClaimAt - now : 0n;

  const canClaim =
    isConnected && !isPending && remaining === 0n && isPriceReady;

  return (
    <Card className="p-6 gap-8 overflow-hidden">
      <div className="flex justify-between text-sm">
        <div>
          <p className="text-xs uppercase tracking-wide text-muted-foreground text-slate-400 font-semibold">
            Last claim
          </p>
          <p className="font-medium text-white text-lg">
            {formatDate(lastClaimAt)}
          </p>
        </div>

        <div className="text-right">
          <p className="text-xs uppercase tracking-wide text-muted-foreground text-slate-400 font-semibold">
            Next claim
          </p>
          <p className="font-medium text-lg text-white">
            {formatRemaining(remaining)}
          </p>
        </div>
      </div>

      <Button
        onClick={claim}
        disabled={!canClaim}
        className="w-full rounded-xl bg-gradient-to-r from-cyan-400 to-blue-500 text-slate-900 font-semibold py-6 hover:opacity-90 transition disabled:opacity-50"
      >
        {!isConnected
          ? "Connect wallet"
          : isPending
          ? "Claiming…"
          : remaining > 0n
          ? "Not available yet"
          : !isPriceReady
          ? "Price is too high"
          : "🎁 Claim Your Reward"}
      </Button>
    </Card>
  );
}
