import React from "react";
import { useRouter } from "next/router";
import { ShowTokenURI } from "../common/ShowTokenURI";
import { useAccount } from "wagmi";
import { useScaffoldContractRead } from "~~/hooks/scaffold-eth";
import { cn } from "~~/utils/cn";

type Props = {
  id: bigint;
  className?: string;
};

export const SteveyWonderCard = ({ id, className }: Props) => {
  const { address } = useAccount();
  const { push } = useRouter();

  const { data: tokenId, isLoading } = useScaffoldContractRead({
    contractName: "SteveyWonder",
    functionName: "tokenOfOwnerByIndex",
    args: [address, id],
    watch: true,
  });

  return (
    <div>
      {isLoading ? (
        <span className="loading loading-bars loading-lg"></span>
      ) : (
        <>
          <div
            className={cn(
              "max-w-fit max-h-fit p-4 rounded-xl bg-[#161829] border border-gray-100 border-opacity-5 cursor-pointer",
              className,
            )}
            onClick={() => {
              push(`/steveywonder/${Number(tokenId)}`);
            }}
          >
            <div className="flex items-center justify-center bg-primary rounded-xl">
              <ShowTokenURI contractName="SteveyWonder" tokenId={tokenId as bigint} width={420} height={420} />
            </div>
            <div className="flex flex-row justify-between px-6 pt-4 text-xl font-medium">
              <span>Stevey Wonder</span>
              <span>#{Number(tokenId)}</span>
            </div>
          </div>
        </>
      )}
    </div>
  );
};
