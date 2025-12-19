"use client";
import { useState, useEffect } from "react";
import { Card } from "../components/ui/card";
import { ConnectButton } from "@rainbow-me/rainbowkit";

export default function Header() {
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect
    setMounted(true);
  }, []);

  return (
    <Card className="flex items-center justify-between p-6">
      <div>
        <h1 className="text-2xl font-bold text-white text-center">
          Rewards Hub
        </h1>
        <p className="text-slate-400">Claim your daily rewards</p>
      </div>

      {mounted ? (
        <ConnectButton />
      ) : (
        <div className="h-10 w-32 bg-slate-700 animate-pulse rounded-md" />
      )}
    </Card>
  );
}
