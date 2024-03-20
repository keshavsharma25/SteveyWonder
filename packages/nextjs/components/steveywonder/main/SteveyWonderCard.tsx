import React from "react";
import { useRouter } from "next/router";
import { ShowTokenURI } from "../common/ShowTokenURI";
import { useAccount } from "wagmi";
import { useScaffoldContractRead } from "~~/hooks/scaffold-eth";
import { cn } from "~~/utils/cn";

type Props = {
  idx: bigint;
  className?: string;
};

export const SteveyWonderCard = ({ idx, className }: Props) => {
  const { address } = useAccount();
  const { push } = useRouter();

  const { data: tokenId } = useScaffoldContractRead({
    contractName: "SteveyWonder",
    functionName: "tokenOfOwnerByIndex",
    args: [address, idx],
    watch: true,
  });

  return (
    <div
      className={cn(
        "p-4 rounded-xl bg-[#161829] border border-gray-100 border-opacity-5 cursor-pointer w-full h-fit",
        className,
      )}
      onClick={() => {
        push(`/steveywonder/${Number(tokenId)}`);
      }}
    >
      <div className="flex items-center justify-center bg-base-100 rounded-xl overflow-hidden w-full h-full">
        <ShowTokenURI contractName="SteveyWonder" tokenId={tokenId as bigint} width={420} height={420} />
      </div>
      <div className="flex flex-row justify-between px-6 pt-4 text-xl font-medium">
        <span>Stevey Wonder</span>
        {!Number.isNaN(Number(tokenId)) ? (
          <span>#{Number(tokenId)}</span>
        ) : (
          <span className="loading loading-dots loading-md"></span>
        )}
      </div>
    </div>
  );
};
