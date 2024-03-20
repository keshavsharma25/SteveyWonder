import { useEffect, useState } from "react";
import Image from "next/image";
import { useTokenURI } from "~~/hooks/steveywonder/useTokenURI";
import { ContractName } from "~~/utils/scaffold-eth/contract";

type Props = {
  contractName: ContractName;
  tokenId: bigint;
  width: number;
  height: number;
};

export const ShowTokenURI = ({ contractName, tokenId, width, height }: Props) => {
  const [isLoading, setIsLoading] = useState<boolean>(true);

  const { tokenURI } = useTokenURI({
    contractName,
    tokenId,
  });

  useEffect(() => {
    if (!tokenURI) {
      setIsLoading(true);
      return;
    }
    setIsLoading(false);
  }, [tokenURI]);

  return isLoading ? (
    <div className="bg-base-200 animate-pulse">
      <Image
        src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSI0NzIiIGhlaWdodD0iNDcyIiB2aWV3Qm94PSIwIDAgNDcyIDQ3MiIgZmlsbD0ibm9uZSI+Cjwvc3ZnPg=="
        alt="loading"
        width={width}
        height={height}
      />
    </div>
  ) : (
    <Image src={`data:image/svg+xml;base64,${tokenURI}`} alt="SteveyWonder Token" width={width} height={height} />
  );
};
