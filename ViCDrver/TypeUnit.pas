unit TypeUnit;

interface

uses nt_status, ntoskrnl, ntutils, fcall, macros;

type
  PDWord = ^DWord;

  _MEMORY_CACHING_TYPE_ORIG = ( 
  MmFrameBufferCached = 2, 
  _MEMORY_CACHING_TYPE_ORIG_TO32BIT = MaxLongint 
  ); 
  MEMORY_CACHING_TYPE_ORIG = _MEMORY_CACHING_TYPE_ORIG;

  _MEMORY_CACHING_TYPE = ( 
  MmNonCached = Byte(FALSE), 
  MmCached = Byte(TRUE), 
  MmWriteCombined = Byte(MmFrameBufferCached), 
  MmHardwareCoherentCached, 
  MmNonCachedUnordered, 
  MmUSWCCached, 
  MmMaximumCacheType, 
  _MEMORY_CACHING_TYPE_TO32BIT = MaxLongint 
  );

  PUNICODE_STRING = ^TUNICODE_STRING;
  TUNICODE_STRING = packed record
    Length: Word;
    MaximumLength: Word;
    Buffer: Pointer;
  end;

  PLIST_ENTRY = ^TLIST_ENTRY;
  TLIST_ENTRY = packed record
    Flink: PLIST_ENTRY;
    Blink: PLIST_ENTRY;
  end;

  PEX_PUSH_LOCK = ^TEX_PUSH_LOCK;
  TEX_PUSH_LOCK = packed record
    case integer of
      0: (Value: Cardinal); //Waiting:Pos 0,1Bit; Exclusive:Pos 1,1Bit ; Shared:Pos 2,30Bit
      1: (Ptr: Pointer);
  end;

  PCLIENT_ID = ^TCLIENT_ID;
  TCLIENT_ID = packed record
    UniqueProcess: Dword;
    UniqueThread: Dword;
  end;

  PPEB_LDR_DATA = ^TPEB_LDR_DATA;
  TPEB_LDR_DATA = packed record // Size: $28
    Length: dword;
    Initialized: byte;
    SsHandle: Pointer;
    InLoadOrderModuleList: TLIST_ENTRY;
    InMemoryOrderModuleList: TLIST_ENTRY;
    InInitializationOrderModuleList: TLIST_ENTRY;
    EntryInProgress: Pointer;
  end;

  PCURDIR = ^TCURDIR;
  TCURDIR = packed record
    DosPath: TUNICODE_STRING;
    Handle: Pointer;
  end;

  PRTL_DRIVE_LETTER_CURDIR = ^TRTL_DRIVE_LETTER_CURDIR;
  TRTL_DRIVE_LETTER_CURDIR = packed record
    Flags: word;
    Length: word;
    TimeStamp: Dword;
    DosPath: TUNICODE_STRING;
  end;

  PRTL_USER_PROCESS_PARAMETERS = ^TRTL_USER_PROCESS_PARAMETERS;
  TRTL_USER_PROCESS_PARAMETERS = packed record
    MaximumLength: Dword;
    Length: Dword;
    Flags: Dword;
    DebugFlags: Dword;
    ConsoleHandle: Pointer;
    ConsoleFlags: Dword;
    StandardInput: Pointer;
    StandardOutput: Pointer;
    StandardError: Pointer;
    CurrentDirectory: TCURDIR;
    DllPath: TUNICODE_STRING;
    ImagePathName: TUNICODE_STRING;
    CommandLine: TUNICODE_STRING;
    Environment: Pointer;
    StartingX: Dword;
    StartingY: Dword;
    CountX: Dword;
    CountY: Dword;
    CountCharsX: Dword;
    CountCharsY: Dword;
    FillAttribute: Dword;
    WindowFlags: Dword;
    ShowWindowFlags: Dword;
    WindowTitle: TUNICODE_STRING;
    DesktopInfo: TUNICODE_STRING;
    ShellInfo: TUNICODE_STRING;
    RuntimeData: TUNICODE_STRING;
    CurrentDirectores: array[0..31] of TRTL_DRIVE_LETTER_CURDIR;
  end;

  PRTL_CRITICAL_SECTION = ^TRTL_CRITICAL_SECTION;
  PRTL_CRITICAL_SECTION_DEBUG = ^TRTL_CRITICAL_SECTION_DEBUG;
  TRTL_CRITICAL_SECTION_DEBUG = record
    Type_18: Word;
    CreatorBackTraceIndex: Word;
    CriticalSection: PRTL_CRITICAL_SECTION;
    ProcessLocksList: TLIST_ENTRY;
    EntryCount: DWORD;
    ContentionCount: DWORD;
    Spare: array[0..1] of DWORD;
  end;

  TRTL_CRITICAL_SECTION = record
    DebugInfo: PRTL_CRITICAL_SECTION_DEBUG;
    LockCount: Longint;
    RecursionCount: Longint;
    OwningThread: THandle;
    LockSemaphore: THandle;
    Reserved: DWORD;
  end;

  PPEB_FREE_BLOCK = ^TPEB_FREE_BLOCK;
  TPEB_FREE_BLOCK = record
    Next: PPEB_FREE_BLOCK;
    Size: Cardinal;
  end;

  PPeb = ^TPeb;
  TPeb = packed record
    InheritedAddressSpace: Byte;
    ReadImageFileExecOptions: Byte;
    BeingDebugged: Byte;
    SpareBool: Byte;
    Mutant: Pointer;
    ImageBaseAddress: Pointer;
    Ldr: PPEB_LDR_DATA;
    ProcessParameters: PRTL_USER_PROCESS_PARAMETERS;
    SubSystemData: Pointer;
    ProcessHeap: Pointer;
    FastPebLock: PRTL_CRITICAL_SECTION;
    FastPebLockRoutine: Pointer;
    FastPebUnlockRoutine: Pointer;
    EnvironmentUpdateCount: Cardinal;
    KernelCallbackTable: Pointer;
    SystemReserved: Dword;
    AtlThunkSListPtr32: Dword;
    FreeList: PPEB_FREE_BLOCK;
    TlsExpansionCounter: Cardinal;
    TlsBitmap: Pointer;
    TlsBitmapBits: array[0..1] of Cardinal;
    ReadOnlySharedMemoryBase: Pointer;
    ReadOnlySharedMemoryHeap: Pointer;
    ReadOnlyStaticServerData: PPointer;
    AnsiCodePageData: Pointer;
    OemCodePageData: Pointer;
    UnicodeCaseTableData: Pointer;
    NumberOfProcessors: Cardinal;
    NtGlobalFlag: Cardinal;
    Gap1: Dword; //??
    CriticalSectionTimeout: Int64;
    HeapSegmentReserve: DWORD;
    HeapSegmentCommit: DWORD;
    HeapDeCommitTotalFreeThreshold: DWORD;
    HeapDeCommitFreeBlockThreshold: DWORD;
    NumberOfHeaps: DWORD;
    MaximumNumberOfHeaps: DWORD;
    ProcessHeaps: PPointer;
    GdiSharedHandleTable: Pointer;
    ProcessStarterHelper: Pointer;
    GdiDCAttributeList: DWORD;
    LoaderLock: Pointer;
    OSMajorVersion: DWORD;
    OSMinorVersion: DWORD;
    OSBuildNumber: word;
    OSCSDVersion: word;
    OSPlatformId: DWORD;
    ImageSubsystem: DWORD;
    ImageSubsystemMajorVersion: DWORD;
    ImageSubsystemMinorVersion: DWORD;
    ImageProcessAffinityMask: DWORD;
    GdiHandleBuffer: array[0..33] of Dword;
    PostProcessInitRoutine: Pointer;
    TlsExpansionBitmap: Pointer;
    TlsExpansionBitmapBits: array[0..31] of Dword;
    SessionId: DWORD;
    AppCompatInfo: Int64;
    AppCompatFlagsUser: Int64;
    pShimData: Pointer;
    AppCompInfo: Pointer;
    CSDVersion: TUNICODE_STRING;
    ActivationContextData: Pointer;
    ProcessAssemblyStorageMap: Pointer;
    SystemDefaultActivationContextData: Pointer;
    SystemAssemblyStorageMap: Pointer;
    MinimumStackCommit: DWORD;
    Gap2: Dword; //??
  end;

  PHANDLE_TRACE_DB_ENTRY = ^THANDLE_TRACE_DB_ENTRY;
  THANDLE_TRACE_DB_ENTRY = packed record //size : $50 byte
    ClientId: TCLIENT_ID;
    Handle: Pointer;
    dType: Dword;
    StackTrace: array[0..15] of Pointer;
  end;

  PHANDLE_TRACE_DEBUG_INFO = ^THANDLE_TRACE_DEBUG_INFO;
  THANDLE_TRACE_DEBUG_INFO = packed record //size : $50004 byte
    CurrentStackIndex: Dword;
    TraceDb: array[0..4095] of THANDLE_TRACE_DB_ENTRY;
  end;

  PEX_FAST_REF = ^TEX_FAST_REF;
  TEX_FAST_REF = packed record
    case Integer of
      0: (pObject: Pointer);
      1: (Value: DWORD);
  end;

  PFAST_MUTEX = ^TFAST_MUTEX;
  TFAST_MUTEX = packed record
    Count: Cardinal;
    Owner: PKTHREAD;
    Contention: DWORD;
    Event: TKEVENT;
    OldIrql: DWORD;
  end;

  POWNER_ENTRY = ^TOWNER_ENTRY;
  TOWNER_ENTRY = packed record
    OwnerThread: Dword;
    case Integer of
      0: (OwnerCount: DWORD);
      1: (TableSize: DWORD);
  end;

  PERESOURCE = ^TERESOURCE;
  TERESOURCE = packed record
    SystemResourcesList: TLIST_ENTRY;
    OwnerTable: POWNER_ENTRY;
    ActiveCount: word;
    Flag: word;
    SharedWaiters: PKSEMAPHORE;
    ExclusiveWaiters: PKEVENT;
    OwnerThreads: array[0..1] of TOWNER_ENTRY;
    ContentionCount: Dword;
    NumberOfSharedWaiters: word;
    NumberOfExclusiveWaiters: word;
    Address: Pointer;
    CreatorBackTraceIndex: Dword;
    SpinLock: Dword;
  end;

  PSID_AND_ATTRIBUTES = ^TSID_AND_ATTRIBUTES;
  TSID_AND_ATTRIBUTES = packed record
    Sid: Pointer;
    Attributes: dword;
  end;

  PPS_JOB_TOKEN_FILTER = ^TPS_JOB_TOKEN_FILTER;
  TPS_JOB_TOKEN_FILTER = packed record
    CapturedSidCount: Cardinal;
    CapturedSids: PSID_AND_ATTRIBUTES;
    CapturedSidsLength: Cardinal;
    CapturedGroupCount: Cardinal;
    CapturedGroups: PSID_AND_ATTRIBUTES;
    CapturedGroupsLength: Cardinal;
    CapturedPrivilegeCount: Cardinal;
    CapturedPrivileges: PSID_AND_ATTRIBUTES;
    CapturedPrivilegesLength: Cardinal;
  end;

  PIO_COUNTERS = ^TIO_COUNTERS;
  TIO_COUNTERS = packed record
    ReadOperationCount: Int64;
    WriteOperationCount: Int64;
    OtherOperationCount: Int64;
    ReadTransferCount: Int64;
    WriteTransferCount: Int64;
    OtherTransferCount: Int64;
  end;

PEJOB = ^TEJOB;
  TEJOB = packed record //size: $180 bytes
    Event: TKEVENT;
    JobLinks: TLIST_ENTRY;
    ProcessListHead: TLIST_ENTRY;
    JobLock: TERESOURCE;
    TotalUserTime: Int64;
    TotalKernelTime: Int64;
    ThisPeriodTotalUserTime: Int64;
    ThisPeriodTotalKernelTime: Int64;
    TotalPageFaultCount: Dword;
    TotalProcesses: Dword;
    ActiveProcesses: Dword;
    TotalTerminatedProcesses: Dword;
    PerProcessUserTimeLimit: Int64;
    PerJobUserTimeLimit: Int64;
    LimitFlags: Dword;
    MinimumWorkingSetSize: Dword;
    MaximumWorkingSetSize: Dword;
    ActiveProcessLimit: Dword;
    Affinity: Dword;
    PriorityClass: Byte;
    UIRestrictionsClass: Dword;
    SecurityLimitFlags: Dword;
    Token: Pointer;
    Filter: PPS_JOB_TOKEN_FILTER;
    EndOfJobTimeAction: Dword;
    CompletionPort: Pointer;
    CompletionKey: Pointer;
    SessionId: Dword;
    SchedulingClass: Dword;
    ReadOperationCount: Int64;
    WriteOperationCount: Int64;
    OtherOperationCount: Int64;
    ReadTransferCount: Int64;
    WriteTransferCount: Int64;
    OtherTransferCount: Int64;
    IoInfo: TIO_COUNTERS;
    ProcessMemoryLimit: Dword;
    JobMemoryLimit: Dword;
    PeakProcessMemoryUsed: Dword;
    PeakJobMemoryUsed: Dword;
    CurrentJobMemoryUsed: Dword;
    MemoryLimitsLock: TFAST_MUTEX;
    JobSetLinks: TLIST_ENTRY;
    MemberLevel: Dword;
    JobFlags: Dword;
  end;

  PEPROCESS_QUOTA_ENTRY = ^TEPROCESS_QUOTA_ENTRY;
  TEPROCESS_QUOTA_ENTRY = packed record
    Usage: DWORD;
    Limit: DWORD;
    Peak: DWORD;
    Return: DWORD;
  end;

  PEPROCESS_QUOTA_BLOCK = ^TEPROCESS_QUOTA_BLOCK;
  TEPROCESS_QUOTA_BLOCK = packed record
    QuotaEntry: array[0..3] of TEPROCESS_QUOTA_ENTRY;
    QuotaList: TLIST_ENTRY;
    ReferenceCount: Cardinal;
    ProcessCount: Cardinal;
  end;

  PPROCESS_WS_WATCH_INFORMATION = ^TPROCESS_WS_WATCH_INFORMATION;
  TPROCESS_WS_WATCH_INFORMATION = packed record
    FaultingPc: Pointer;
    FaultingVa: Pointer;
  end;

  PPAGEFAULT_HISTORY = ^TPAGEFAULT_HISTORY;
  TPAGEFAULT_HISTORY = packed record
    CurrentIndex: DWORD;
    MaxIndex: DWORD;
    SpinLock: DWORD;
    Reserved: Pointer;
    WatchInfo: TPROCESS_WS_WATCH_INFORMATION;
  end;

  PHARDWARE_PTE_X86 = ^THARDWARE_PTE_X86;
  THARDWARE_PTE_X86 = packed record
    Bit: Dword;
   // Valid: Bitfield Pos 0, 1 Bit
   // Write: Bitfield Pos 1, 1 Bit
   // Owner: Bitfield Pos 2, 1 Bit
   // WriteThrough: Bitfield Pos 3, 1 Bit
   // CacheDisable: Bitfield Pos 4, 1 Bit
   // Accessed: Bitfield Pos 5, 1 Bit
   // Dirty: Bitfield Pos 6, 1 Bit
   // LargePage: Bitfield Pos 7, 1 Bit
   // Global: Bitfield Pos 8, 1 Bit
   // CopyOnWrite: Bitfield Pos 9, 1 Bit
   // Prototype: Bitfield Pos 10, 1 Bit
   // reserved: Bitfield Pos 11, 1 Bit
   // PageFrameNumber: Bitfield Pos 12, 20 Bits
  end;

  PHANDLE_TABLE = ^THANDLE_TABLE;
  THANDLE_TABLE = packed record
    TableCode: Dword;
    QuotaProcess: PEPROCESS;
    UniqueProcessId: Pointer;
    HandleTableLock: array[0..3] of TEX_PUSH_LOCK;
    HandleTableList: TLIST_ENTRY;
    HandleContentionEvent: TEX_PUSH_LOCK;
    DebugInfo: PHANDLE_TRACE_DEBUG_INFO;
    ExtraInfoPages: Dword;
    FirstFree: Dword;
    LastFree: Dword;
    NextHandleNeedingPool: Dword;
    HandleCount: Dword;
    Flags: Dword;
  end;

PEX_RUNDOWN_REF = ^TEX_RUNDOWN_REF;
  TEX_RUNDOWN_REF = packed record
    case integer of
      0: (Count: Cardinal);
      1: (Ptr: Pointer);
  end;

  TDISPATCHER_HEADER = packed record
    bType: byte;
    bAbsolute: byte;
    Size: byte;
    Inserted: byte;
    SignalState: DWORD;
    WaitListHead: TLIST_ENTRY;
  end;

  TKGDTENTRY = packed record
    LimitLow: Word;
    BaseLow: Word;
    HighWord: packed record
      BaseMid: Byte;
      Flags1: Byte;
      Flags2: Byte;
      BaseHi: Byte;
    end;
  end;

  TKIDTENTRY = packed record
    Offset: Word;
    Selector: Word;
    Access: Word;
    ExtendedOffset: Word;
  end;

  PSINGLE_LIST_ENTRY = ^TSINGLE_LIST_ENTRY;
  TSINGLE_LIST_ENTRY = packed record
    Next: PSINGLE_LIST_ENTRY;
  end;

  PKPROCESS = ^TKPROCESS;
  TKPROCESS = packed record
    Header: TDISPATCHER_HEADER;
    ProfileListHead: TLIST_ENTRY;
    DirectoryTableBase: array[0..1] of Dword;
    LdtDescriptor: TKGDTENTRY;
    Int21Descriptor: TKIDTENTRY;
    IopmOffset: Word;
    Iopl: Byte;
    Unused: Byte;
    ActiveProcessors: DWORD;
    KernelTime: DWORD;
    UserTime: DWORD;
    ReadyListHead: TLIST_ENTRY;
    SwapListEntry: TSINGLE_LIST_ENTRY;
    VdmTrapcHandler: Pointer;
    ThreadListHead: TLIST_ENTRY;
    ProcessLock: DWORD;
    Affinity: DWORD;
    StackCount: Word;
    BasePriority: Char;
    ThreadQuantum: Char;
    AutoAlignment: Byte;
    State: Byte;
    ThreadSeed: Byte;
    DisableBoost: Byte;
    PowerState: Byte;
    DisableQuantum: Byte;
    IdealNode: Byte;
    case Integer of
      0: (Flags: byte);
      1: (ExecuteOptions: byte);
  end;

  POBJECT_NAME_INFORMATION = ^TOBJECT_NAME_INFORMATION;
  TOBJECT_NAME_INFORMATION = packed record
    Name: TUNICODE_STRING;
  end;

  PSE_AUDIT_PROCESS_CREATION_INFO = ^TSE_AUDIT_PROCESS_CREATION_INFO;
  TSE_AUDIT_PROCESS_CREATION_INFO = packed record
    ImageFileName: POBJECT_NAME_INFORMATION;
  end;

  PMMSUPPORT_FLAGS = ^TMMSUPPORT_FLAGS;
  TMMSUPPORT_FLAGS = packed record
    Bit: DWORD;
   //SessionSpace     : Bitfield Pos 0, 1 Bit
   //BeingTrimmed     : Bitfield Pos 1, 1 Bit
   //SessionLeader    : Bitfield Pos 2, 1 Bit
   //TrimHard         : Bitfield Pos 3, 1 Bit
   //WorkingSetHard   : Bitfield Pos 4, 1 Bit
   //AddressSpaceBeingDeleted : Bitfield Pos 5, 1 Bit
   //Available        : Bitfield Pos 6, 10 Bits
   //AllowWorkingSetAdjustment : Bitfield Pos 16, 8 Bits
   //MemoryPriority   : Bitfield Pos 24, 8 Bits
  end;

  PMMWSL = ^TMMWSL;
  TMMWSL = packed record
    //MS Undefined
  end;

  PMMSUPPORT = ^TMMSUPPORT;
  TMMSUPPORT = packed record
    LastTrimTime: Int64;
    Flags: TMMSUPPORT_FLAGS;
    PageFaultCount: Dword;
    PeakWorkingSetSize: Dword;
    WorkingSetSize: Dword;
    MinimumWorkingSetSize: Dword;
    MaximumWorkingSetSize: Dword;
    VmWorkingSetList: PMMWSL;
    WorkingSetExpansionLinks: TLIST_ENTRY;
    Claim: Dword;
    NextEstimationSlot: Dword;
    NextAgingSlot: Dword;
    EstimatedAvailable: Dword;
    GrowthSinceLastEstimate: Dword;
  end;
  
  TEPROCESS = packed record
    Pcb: TKPROCESS;
    ProcessLock: TEX_PUSH_LOCK;
    CreateTime: Int64;
    ExitTime: Int64;
    RundownProtect: TEX_RUNDOWN_REF;
    UniqueProcessId: Integer;
    ActiveProcessLinks: TLIST_ENTRY;
    QuotaUsage: array[0..2] of Cardinal;
    QuotaPeak: array[0..2] of Cardinal;
    CommitCharge: Cardinal;
    PeakVirtualSize: Cardinal;
    VirtualSize: Cardinal;
    SessionProcessLinks: TLIST_ENTRY;
    DebugPort: Pointer;
    ExceptionPort: Pointer;
    ObjectTable: PHANDLE_TABLE;
    Token: TEX_FAST_REF;
    WorkingSetLock: TFAST_MUTEX;
    WorkingSetPage: Cardinal;
    AddressCreationLock: TFAST_MUTEX;
    HyperSpaceLock: Cardinal;
    ForkInProgress: PEThread;
    HardwareTrigger: Cardinal;
    VadRoot: Pointer;
    VadHint: Pointer;
    CloneRoot: Pointer;
    NumberOfPrivatePages: Cardinal;
    NumberOfLockedPages: Cardinal;
    Win32Process: Pointer;
    Job: PEJOB;
    SectionObject: Pointer;
    SectionBaseAddress: Pointer;
    QuotaBlock: PEPROCESS_QUOTA_BLOCK;
    WorkingSetWatch: PPAGEFAULT_HISTORY;
    Win32WindowStation: Pointer;
    InheritedFromUniqueProcessId: Cardinal;
    LdtInformation: Pointer;
    VadFreeHint: Pointer;
    VdmObjects: Pointer;
    DeviceMap: Pointer;
    PhysicalVadList: TLIST_ENTRY;
    Union1: record case integer of
        0: (PageDirectoryPte: THARDWARE_PTE_X86);
        1: (Filler: Int64);
    end;
    Session: Pointer;
    ImageFileName: array[0..$F] of Char;
    JobLinks: TLIST_ENTRY;
    LockedPagesList: Pointer;
    ThreadListHead: TLIST_ENTRY;
    SecurityPort: Pointer;
    PaeTop: Pointer;
    ActiveThreads: Cardinal;
    GrantedAccess: Cardinal;
    DefaultHardErrorProcessing: Cardinal;
    LastThreadExitStatus: Dword;
    Peb: PPeb;
    PrefetchTrace: TEX_FAST_REF;
    ReadOperationCount: Int64;
    WriteOperationCount: Int64;
    OtherOperationCount: Int64;
    ReadTransferCount: Int64;
    WriteTransferCount: Int64;
    OtherTransferCount: Int64;
    CommitChargeLimit: Cardinal;
    CommitChargePeak: Cardinal;
    AweInfo: Pointer;
    SeAuditProcessCreationInfo: TSE_AUDIT_PROCESS_CREATION_INFO;
    Vm: TMMSUPPORT;
    LastFaultCount: Cardinal;
    ModifiedPageCount: Cardinal;
    NumberOfVads: Cardinal;
    JobStatus: Cardinal;
    Flags: Cardinal;
    ExitStatus: DWORD;
    NextPageColor: Word;
    Union2: record case integer of
        0: (SSV: record SubSystemMinorVersion: Byte; SubSystemMajorVersion: Byte; end);
        1: (SubSystemVersion: Word);
    end;
    SubSystemVersion: Word;
    PriorityClass: Byte;
    WorkingSetAcquiredUnsafe: Byte;
    Cookie: Cardinal;
    Gap: DWORD; //??
  end;
  EPROCESS = TEPROCESS;

implementation

end.

