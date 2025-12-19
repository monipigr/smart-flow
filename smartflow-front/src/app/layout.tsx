"use client";
import "./globals.css";
import { ReactNode } from "react";
import { WagmiProvider } from "wagmi";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { getDefaultConfig, RainbowKitProvider } from "@rainbow-me/rainbowkit";
import "@rainbow-me/rainbowkit/styles.css";
import { arbitrum } from "wagmi/chains";
import { Toaster } from "sonner";

const config = getDefaultConfig({
  appName: "SmartFlow",
  projectId: "f7ed284ea8f5476e58f7050a03801bd3",
  chains: [arbitrum],
});

const queryClient = new QueryClient();

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="en">
      <body>
        <WagmiProvider config={config}>
          <QueryClientProvider client={queryClient}>
            <RainbowKitProvider>{children}</RainbowKitProvider>
            <Toaster richColors position="top-right" />
          </QueryClientProvider>
        </WagmiProvider>
      </body>
    </html>
  );
}
