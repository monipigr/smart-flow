"use client";

import { Card } from "@/components/ui/card";
import { Progress } from "@/components/ui/progress";
import { useAccount, useBalance } from "wagmi";
import { Shield, Star, Crown, Gem } from "lucide-react";
import { useEffect, useState, cloneElement, ReactElement } from "react";
import { FLOW_TOKEN_ADDRESS } from "@/hooks/useSmartFlow";

type Tier = "Basic" | "Silver" | "Gold" | "Elite";

const TIERS: {
  name: Tier;
  min: number;
  max: number | null;
  color: string;
  icon: ReactElement<SVGProps<SVGSVGElement>>;
}[] = [
  {
    name: "Basic",
    min: 0,
    max: 19,
    color: "text-yellow-400",
    icon: <Shield className="w-5 h-5" />,
  },
  {
    name: "Silver",
    min: 20,
    max: 49,
    color: "text-yellow-100",
    icon: <Star className="w-5 h-5" />,
  },
  {
    name: "Gold",
    min: 50,
    max: 99,
    color: "text-lime-400",
    icon: <Crown className="w-5 h-5" />,
  },
  {
    name: "Elite",
    min: 100,
    max: null,
    color: "text-emerald-400",
    icon: <Gem className="w-5 h-5" />,
  },
];

function getTier(balance: number) {
  return (
    TIERS.find(
      (t) => balance >= t.min && (t.max === null || balance <= t.max)
    ) ?? TIERS[0]
  );
}

export default function MembershipCard() {
  const { address, isConnected } = useAccount();
  const { data: balance } = useBalance({
    address,
    token: FLOW_TOKEN_ADDRESS,
  });
  const [mounted, setMounted] = useState(false);

  const flw = balance ? Number(balance.value) / 10 ** balance.decimals : 0;

  const tier = getTier(flw);

  const progress = flw <= 0 ? 3 : flw >= 100 ? 100 : Number(flw.toFixed(0));

  useEffect(() => {
    //eslint-disable-next-line
    setMounted(true);
  }, []);

  return (
    <Card className=" overflow-hidden p-6 gap-6">
      <div className="flex items-center justify-between">
        <div>
          <p className="text-sm uppercase tracking-wide text-slate-400 font-extralight pb-6">
            Membership level
          </p>
          <div
            className={`flex items-center gap-2 font-semibold text-lg p-2 ${tier.color}`}
          >
            <span
              className="
                flex h-11 w-11 items-center justify-center
                rounded-2xl
                bg-white/5
                shadow-[0_0_30px_rgba(255,215,0,0.75)]
                backdrop-blur
                "
            >
              {cloneElement(tier.icon, {
                className: "w-8 h-8 ${tier.color}",
              })}
            </span>
            <span className="pl-4 text-2xl">{tier.name}</span>
          </div>
        </div>

        <div className="text-right text-sm">
          <p className="font-extralight text-2xl text-white">
            {!mounted ? "—" : isConnected ? flw.toFixed(0) : "—"}
          </p>
          <p className="font-semibold text-white">FLW</p>
        </div>
      </div>

      {/* Progress bar */}
      <div className="text-slate-800">
        <Progress
          value={progress}
          className="h-2 bg-white/10 [&>div]:bg-gradient-to-r
    from-emerald-400
    via-yellow-100
    to-yellow-400"
        />
        <div className="flex justify-between text-xs text-muted-foreground pt-2">
          <span className="text-white">{TIERS[0].min} </span>
          <span className="text-white">{TIERS[3].min} FLW</span>
        </div>
      </div>

      {/* Tier row */}
      <div className="flex justify-between text-xs text-muted-foreground">
        {TIERS.map((t) => (
          <div
            key={t.name}
            className={`flex flex-col items-center gap-1 text-white ${
              t.name === tier.name ? "opacity-100" : "opacity-40"
            }`}
          >
            {t.icon}
            <span>{t.name}</span>
          </div>
        ))}
      </div>
    </Card>
  );
}
