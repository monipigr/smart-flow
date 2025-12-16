import { Card } from "../components/ui/card";
import { ConnectButton } from "@rainbow-me/rainbowkit";

export default function Header() {
  return (
    <Card className="flex items-center justify-between p-6 bg-gradient-to-br from-slate-900 to-slate-800">
      <div>
        <h1 className="text-2xl font-bold text-white">Rewards Hub</h1>
        <p className="text-slate-400">Claim your daily rewards</p>
      </div>

      <ConnectButton />
    </Card>
  );
}
